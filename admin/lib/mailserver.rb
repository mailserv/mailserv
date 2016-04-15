class Mailserver

  def processes
    {
      :clamd      => %x{ps -ax | egrep clamd | grep -v grep | wc -l}.to_i > 0,
      :postfix    => system('rcctl check postfix'),
      :dovecot    => system('rcctl check dovecot'),
      :mysqld     => system('rcctl check mysqld'),
      :spamd      => %x{ps -ax | egrep spamd | grep -v grep | wc -l}.to_i > 0,
      :freshclam  => %x{ps -ax | egrep freshclam | grep -v grep | wc -l}.to_i > 0,
      :dnsmasq    => system('rcctl check dnsmasq'),
      :memcached  => system('rcctl check memcached'),
      :nginx      => system('rcctl check nginx'),
	  :ntpd       => system('rcctl check ntpd'),
      :php        => %x{ps -ax | egrep php-fpm | grep -v grep | wc -l}.to_i > 0
    }
  end

  def updates
    begin
    {
      :spamassassin => File.ctime("/var/db/spamassassin/" + `ls -t /var/db/spamassassin/ | head -1`.strip),
      :clam => File.ctime("/var/db/clamav/" + `ls -t /var/db/clamav/ | head -1`.strip)
    }
    rescue
      {:spamassassin => Date.today, :clam => Date.today}
    end
  end

end
