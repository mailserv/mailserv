class Mailserver

  def processes
    {
      :clamd      => system('rcctl check clamd'),
      :postfix    => system('rcctl check postfix'),
      :dovecot    => system('rcctl check dovecot'),
      :mysqld     => system('rcctl check mysqld'),
      :spamd      => system('rcctl check spamassassin'),
      :freshclam  => system('rcctl check freshclam'),
      :dnsmasq    => system('rcctl check dnsmasq'),
      :memcached  => system('rcctl check memcached'),
      :nginx      => system('rcctl check nginx'),
      :ntpd       => system('rcctl check ntpd'),
      :php        => system('rcctl check php56_fpm')
    }
  end

  def updates
    begin
    {
      :spamassassin => File.ctime("/var/db/spamassassin/" + `ls -t /var/db/spamassassin/ | head -1`.strip),
      :clam => File.ctime("/var/db/clamav/" + `ls -t /var/db/clamav/ | head -1`.strip),
      :ntpstatus => `doas ntpctl -s status | awk -F"clock " '{print $2}' | awk -F"," '{print $1}'`
    }
    rescue
      {:spamassassin => Date.today, :clam => Date.today, ntpstatus => '-'}
    end
  end

end
