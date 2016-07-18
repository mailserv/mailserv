class System
  attr_reader :os_version, :version, :cpu_type, :timezone, :memory, :needs_update
  attr_writer :timezone

  def initialize
    @os_version       = %x{uname -r}.strip
    @os_version_short = @os_version.gsub(/\./, "")
    @cpu_type         = %x{uname -p}.strip
    @memory           = %x{sysctl hw.usermem | sed 's/=/ /' | awk '{print $2}'}.to_i / 1048576 + 1
    @version          = %x{uname -srv}.strip
    @timezone         = Timezone.new
  end

  def hostname
    %x{hostname}.strip
  end

  def update
    @update ||= Update.new
  end

  def uptime
    uptime = %x{uptime}
    if uptime =~ /up\s+([\d:]+),/
      return $1
    elsif uptime =~ /up\s+([\d]+\s+[a-z]+),/
      return $1
    end
  end

  def disk_utilization
    output = Array.new
    %x{df -h}.split("\n").each_with_index do |line, index|
      next if index == 0
      filesystem, size, used, avail, capacity, mounted_on = line.split
      output << {
        :filesystem => filesystem,
        :size => size,
        :used => used,
        :avail => avail,
        :capacity => capacity,
        :mounted_on => mounted_on
      }
    end
    output
  end

  #
  # System Commands
  #
  def reconfig(function = "all")
    case function
    when "hostname"
      Sudo.exec("/usr/local/bin/mailserv system:reload_hostname &")
    when "all"
      Sudo.exec("
        /usr/local/bin/mailserv system:update_hostname &&
        /usr/local/bin/god restart mailserv &")
    when "certificates"
      Sudo.exec("/usr/local/bin/mailserv system:reload &")
    else
      Sudo.exec("/usr/local/bin/god restart #{function}")
    end
  end

  def reboot
    Sudoe.exec("shutdown -r now")
  end

  def shutdown
    Sudo.exec("shutdown -hp now")
  end
  
end
