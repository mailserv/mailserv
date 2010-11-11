class Greylist < ActiveRecord::Base
  acts_as_list
  validates_presence_of :description, :action
  validates_uniqueness_of :description
  validates_format_of :description, :with => /^[\w\d\s]+$/

  after_save :write_config
  after_destroy :write_config

  def to_s
    (description.blank? ? "Greylist" : description.to_s)
  end

  def after_initialize
    if new_record?
      self.action = "whitelist" unless self.action
      self.clause = "addr" unless self.clause
    end
  end

  def write_config
    logger.debug build_list
    Sudo.write(Sudo.read("/usr/local/share/mailserver/template/greylist.conf") + "\n\n" + build_list, "/etc/mail/greylist.conf")
  end

  def validate
    unless config_valid?
      tempfile = Sudo.tempfile(Sudo.read("/usr/local/share/mailserver/template/greylist.conf") + build_entry(self))
      Sudo.exec("/usr/local/libexec/milter-greylist -c -f #{tempfile} 2>&1").to_s.strip.each_line do |line|
        line_no = line.match(/line\s+(\d+):\s+(.*)/)[1]
        error_desc = line.match(/line\s+(\d+):\s+(.*)/)[2]
        errors.add_to_base "#{error_desc}: " + %x{head -#{line_no} #{tempfile} | tail -1}.strip.gsub(/\\\s*$/, '')
      end
    end
  end

  def config_valid?
    if File.exists?("/usr/local/libexec/milter-greylist")
      tempfile = Sudo.tempfile(File.read("/usr/local/share/mailserver/template/greylist.conf") + build_entry(self))
      Sudo.exec("/usr/local/libexec/milter-greylist -c -f #{tempfile} >/dev/null 2>&1; echo $?").to_i.zero?
    else
      true
    end
  end

  def build_list
    lists = ""
    acls = ""
    Greylist.all(:order => :position).each do |entry|
      if entry.value.to_s.split(/[\s,]+/).size > 1
        lists += "list \"#{entry.description}\" #{entry.clause} { \\\n  "
        lists += entry.value.to_s.split(/[\s,]+/).join(" \\\n  ")
        lists += " \\\n}\n\n"
        acls += "racl #{entry.action} list \"#{entry.description}\""
        acls += " rcpt #{entry.rcpt}" unless entry.rcpt.blank?
      else
        acls += "racl #{entry.action}"
        acls += " #{entry.clause} #{entry.value}" unless entry.clause.blank?
        acls += " rcpt #{entry.rcpt}" unless entry.rcpt.blank?
      end
      acls += "\n"
    end
    lists + acls + "racl greylist default delay 30m autowhite 32d\n"
  end

  def build_entry(entry)
    lists = ""
    acls = ""
    if entry.value.to_s.split(/[\s,]+/).size > 1
      lists += "list \"#{entry.description}\" #{entry.clause} { \\\n  "
      lists += entry.value.to_s.split(/[\s,]+/).join(" \\\n  ")
      lists += " \\\n}\n\n"
      acls += "racl #{entry.action} list \"#{entry.description}\""
      acls += " rcpt #{entry.rcpt}" unless entry.rcpt.blank?
    else
      acls += "racl #{entry.action}"
      acls += " #{entry.clause} #{entry.value}" unless entry.clause.blank?
      acls += " rcpt #{entry.rcpt}" unless entry.rcpt.blank?
    end
    acls += "\n"
    lists + acls + "racl greylist default delay 30m autowhite 32d\n"
  end

  def self.greylisted
    out = []
    Sudo.read("/var/db/milter-greylist/greylist.db").match(/.*greylisted tuples(.*)Auto-whitelisted tuples/m)[1].each_line do |line|
      next if line =~ /^$/ || line =~ /^#/
      ip, from, to, time2, time3, date, time = line.split
      out << {
        :ip => ip,
        :from => from,
        :to => to,
        :time => date.to_s + " " + time.to_s
      }
    end if Sudo.file_exists?("/var/db/milter-greylist/greylist.db")
    out
  end

  def self.whitelisted
    out = []
    Sudo.read("/var/db/milter-greylist/greylist.db").match(/.*Auto-whitelisted tuples(.*)/m)[1].each_line do |line|
      next if line =~ /^$/ || line =~ /^#/
      ip, from, to, time2, time3, time4, date, time = line.split
      out << {
        :ip => ip,
        :from => from,
        :to => to,
        :expire => date.to_s + " " + time.to_s
      }
    end if Sudo.file_exists?("/var/db/milter-greylist/greylist.db")
    out
  end

  def self.enabled?
    if Rails.env.production?
      Sudo.exec("/usr/local/sbin/postconf smtpd_milters | grep 9323 | wc -l").to_i > 0
    else
      true
    end
  end

  def self.enable
    Sudo.exec "/usr/local/sbin/postconf -e 'smtpd_milters=inet:127.0.0.1:9323 unix:/tmp/clamav-milter.sock'; /usr/local/sbin/postfix reload"
  end

  def self.disable
    Sudo.exec "/usr/local/sbin/postconf -e 'smtpd_milters=unix:/tmp/clamav-milter.sock'; /usr/local/sbin/postfix reload"
  end

end
