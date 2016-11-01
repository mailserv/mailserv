class Backup < ActiveRecord::Base
  validates_confirmation_of :encryption_key

  def validate
    if !location.match(/^(ftp|https)/)
      errors.add("location", "protocol needs to be ftp or https")
    else
      unless Rails.env.test?
        result = %x{echo `date` | /usr/local/bin/curl -m 10 -ksST - #{location}/backup-test-`hostname`-`date +%Y%m%d%H%M%S`.txt 2>&1; echo $?}.split("\n")
        errors.add("location", result[0].strip.gsub(/curl.\s+\(\d+\)\s+/,'')) unless result[-1].to_i.zero?
      end
    end unless location.blank?
  end

  def location_with_slash
    location.match(/.*\/$/) ? location : location + "/" rescue ""
  end

  def list
    output = []
    Sudo.exec("/usr/local/bin/curl -kls #{location_with_slash}").split("\n").each do |entry|
      output << entry if entry.match(/^backup\-#{System.new.hostname}/)
    end
    output.sort
  end

  def list_content(filename = "")
    out = []
    Sudo.exec("ls /var/mailserv/mail").split.each do |dir|
      out << dir
      Sudo.exec("ls /var/mailserv/mail/#{dir}").split.each do |user|
        out << "#{dir}/#{user}"
      end
    end
    out
  end

  def self.is_running?
    %x{pgrep -f mailserv:backup}.to_i > 0
  end

  def self.restore_is_running?
    %x{pgrep -f mailserv:restore}.to_i > 0
  end

  def self.start_full
    Sudo.rake "mailserv:backup:full"
  end

  def self.abort_backup
    Sudo.killall "mailserv:backup"
  end

end
