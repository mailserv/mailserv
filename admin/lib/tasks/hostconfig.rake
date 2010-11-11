$stdout.sync = true
require 'tempfile'
namespace :system do
  @templates = "/usr/local/share/mailserver/template"
  @hostname = %x{hostname}.strip

  desc "Update hostname, generate certificates and reload services"
  task :reload_certificate_hostname => [ :generate_certificate, :update_hostname, :reload]

  desc "Update hostname and reload services"
  task :reload_hostname => [ :update_hostname, :reload]

  desc "Reload services"
  task :reload do
    exec("
      /usr/local/sbin/nginx -s reload    > /dev/null &&
      /usr/local/bin/god restart dovecot > /dev/null &&
      /usr/local/bin/god restart postfix > /dev/null &
    ")
  end

  desc "Rewrite system files that uses hostnames to the current hostname"
  task :update_hostname => [ :dovecot, :postfix, :awstats ]

  task :dovecot do
    filename = "/etc/dovecot.conf"
    if !File.exists?(filename) || !File.size?(filename) || ENV['RESET'] == "true"
      dovecot_conf = File.read("#{@templates}/dovecot.conf").gsub(/^\s*postmaster_address.*/,"  postmaster_address = postmaster@#{@hostname}")
    else
      dovecot_conf = File.read(filename).gsub(/^\s*postmaster_address.*/,"  postmaster_address = postmaster@#{@hostname}")
    end
    tf = Tempfile.new("_dovecot")
    tf.puts dovecot_conf
    tf.close
    %x{install -m 644 #{tf.path} #{filename}}
  end

  task :postfix do
    %x{install -C -m 644 /etc/services /etc/resolv.conf /etc/localtime /var/spool/postfix/etc}
  end

  task :awstats do
    tf = Tempfile.new("_awstats")
    tf.puts File.read("#{@templates}/awstats_cron-stats").gsub(/localhost/, @hostname)
    tf.close
    %x{install -m 755 #{tf.path} /usr/local/awstats/cron-stats}

    awstats = File.read("#{@templates}/awstats_awstats.localhost.conf")
    awstats.gsub!(/^SiteDomain=.*/, "SiteDomain=\"#{@hostname}\"")
    awstats.gsub!(/^HostAliases=.*/, "HostAliases=\"#{@hostname}\"")
    tf = Tempfile.new("_awstats")
    tf.puts awstats
    tf.close
    %x{
      [[ ! -d /etc/awstats ]] && mkdir /etc/awstats
      install -m 644 #{tf.path} /etc/awstats/awstats.#{@hostname}.conf
    }

    tf = Tempfile.new("_awstats")
    tf.puts '<META HTTP-EQUIV="Refresh" CONTENT="0; URL=awstats.html">'
    tf.close
    %x{install -m 644 #{tf.path} /var/www/admin/public/awstats/awstats.#{@hostname}.html}
    system("/usr/local/awstats/cron-stats > /dev/null 2>&1 &")
  end

  def selfsigned?
    text = %x{/usr/sbin/openssl x509 -text -noout -in /etc/ssl/server.crt}.strip
    issuer  = text.match(/Issuer.*CN=(.*)[,\n]/)[1]
    subject = text.match(/Subject:.*CN=(.*)[,\n]/)[1]
    issuer == subject
  end

  desc "Generates a new self-signed certificate if the current certificate is self-signed"
  task :generate_certificate do
    if selfsigned?
      tf = Tempfile.new("_csr")
      %x{
        /usr/sbin/openssl genrsa -out /etc/ssl/private/server.key 2048 2>/dev/null
        /usr/sbin/openssl req -new -key /etc/ssl/private/server.key -out #{tf.path} -subj "/CN=#{@hostname} -sha1" 2>/dev/null
        /usr/sbin/openssl x509 -req -days 1095 -in #{tf.path} -signkey /etc/ssl/private/server.key -out /etc/ssl/server.crt 2>/dev/null
      }
    end
  end

end
