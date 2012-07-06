require 'timeout'
class Ntp < ActiveRecord::BaseWithoutTable
  column :name_1, :string
  column :name_2, :string
  column :name_3, :string
  column :enabled, :boolean

  def after_initialize
    i = 0
    Sudo.read("/etc/ntpd.conf").each do |line|
      case
      when line =~ /server (.*)/
        add_server $1, i += 1
      when line =~ /servers (.*)/
        add_server $1, i += 1
      end
    end
    self.enabled = false
    Sudo.read("/etc/rc.conf.local").each do |line|
      case
      when line =~ /ntpd_flags=\"(\"|\s*\-)/
        self.enabled = true
      end
    end
  end

  def add_server(name, number)
    case number
    when 1
      self.name_1 = name
    when 2
      self.name_2 = name
    when 3
      self.name_3 = name
    end
  end

  def save
    out  = ""
    out += (is_pool?(name_1) ? "servers" : "server") + " #{name_1}\n" unless name_1.blank?
    out += (is_pool?(name_2) ? "servers" : "server") + " #{name_2}\n" unless name_2.blank?
    out += (is_pool?(name_3) ? "servers" : "server") + " #{name_3}\n" unless name_3.blank?
    Sudo.write("/etc/ntpd.conf", out, :mode => 644)

    out = ""
    ntp_is_set = false
    rc_conf_local = Sudo.read("/etc/rc.conf.local").each do |line|
      if line =~ /^ntpd_flags/
        out += "ntpd_flags=\"-s\"\n" if enabled
        ntp_is_set = true
      elsif line =~ /^\s*$/
        next
      else
        out += line.strip + "\n"
      end
    end
    unless ntp_is_set
      out += "ntpd_flags=\"-s\"" if enabled
    end
    Sudo.write("/etc/rc.conf.local", out)
    if %x{uname -s}.strip == "OpenBSD"
        Sudo.exec "pkill ntpd"
        Sudo.exec "/usr/sbin/ntpd" if enabled
    end
    true
  end

  def self.test(ntpserver)
    return nil if ntpserver.blank?
    begin
      Timeout::timeout(3) do

        sock = UDPSocket.new
        sock.connect(ntpserver, "ntp")

        client_time_send = Time.new.to_i
        client_localtime = client_time_send
        client_adj_localtime = client_localtime + 2208988800
        client_frac_localtime = frac2bin(client_adj_localtime)

        ntp_msg =
          (['00011011']+Array.new(12, 0)+[client_localtime, client_frac_localtime.to_s]).pack("B8 C3 N10 B32")

        sock.print ntp_msg
        sock.flush
        data = sock.recvfrom(960)[0]

        true
      end
    rescue Timeout::Error
      false
    rescue
      false
    end
  end

  private
  
  def self.frac2bin(frac)
    bin  = ''
    while ( bin.length < 32 ) 
      bin  += ( frac * 2 ).to_i.to_s
      frac = ( frac * 2 ) - ( frac * 2 ).to_i 
    end
    return bin
  end

  def is_pool?(address)
    return nil if address.blank?
    begin
      Timeout::timeout(3) do
        Resolv::DNS.new.getaddresses(address).count > 1
      end
    rescue Timeout::Error
      false
    rescue
      false
    end
  end

end
