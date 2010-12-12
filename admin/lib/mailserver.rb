class Mailserver

  def processes
    {
      :clamd      => %x{ps -ax | egrep clamd | grep -v grep | wc -l}.to_i > 0,
      :postfix    => %x{ps -ax | egrep postfix\/master | grep -v grep | wc -l}.to_i > 0,
      :dovecot    => %x{ps -ax | egrep dovecot$ | grep -v grep | wc -l}.to_i > 0,
      :mysqld     => %x{ps -ax | egrep "mysqld " | grep -v grep | wc -l}.to_i > 0,
      :spamd      => %x{ps -ax | egrep "spamd " | grep -v grep | wc -l}.to_i > 0,
      :freshclam  => %x{ps -ax | egrep "freshclam " | grep -v grep | wc -l}.to_i > 0
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
