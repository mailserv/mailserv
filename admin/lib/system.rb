class System
  attr_reader :os_version, :version, :cpu_type, :timezone, :memory, :needs_update
  attr_writer :timezone

  def initialize
    @os_version       = %x{uname -r}.strip
    @os_version_short = @os_version.gsub(/\./, "")
    @cpu_type         = %x{uname -p}.strip
    @memory           = %x{sysctl hw.usermem | sed 's/=/ /' | awk '{print $2}'}.to_i / 1048576 + 1

    @version          = Version.new
    @long_version     = "#{CONF["product"].capitalize} #{@os_version} release #{@version}"
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
      system("/usr/local/bin/mailserver system:reload_hostname &")
    when "all"
      system("
        /usr/local/bin/mailserver system:update_hostname &&
        /usr/local/bin/god restart mailserver &")
    when "certificates"
      system("/usr/local/bin/mailserver system:reload &")
    else
      system("/usr/local/bin/god restart #{function}")
    end
  end

  def reload_awstats
    templates = "/usr/local/share/mailserver/template"
    File.open("/usr/local/awstats/cron-stats", "w") do |f|
      f.puts File.open(templates + "/awstats_cron-stats").read.gsub(/localhost/, hostname)
    end
    %x{chmod 755 /usr/local/awstats/cron-stats}
    %x{mkdir /etc/awstats} unless File.directory?("/etc/awstats")
    File.open("/etc/awstats/awstats." + hostname + ".conf", "w") do |f|
      f.puts File.open(templates + "/awstats_awstats.localhost.conf").read.gsub(/^SiteDomain=.*/, "SiteDomain='#{hostname}'").gsub(/^HostAliases=.*/, "HostAliases='#{hostname}'")
    end
    File.open("/var/www/admin/public/awstats/awstats." + hostname + ".html", "w") do |f|
      f.puts '<META HTTP-EQUIV="Refresh" CONTENT="0; URL=awstats.html">'
    end
    system "/usr/local/awstats/cron-stats > /dev/null 2>&1 &"
  end

  def reboot
    %x{shutdown -r now}
  end

  def reboot_at(time)
    %x{shutdown -r #{time}}
  end

  def shutdown
    %x{shutdown -hp now}
  end
  
  def shutdown_at(time)
    %x{shutdown -hp #{time}}
  end

end
