class Ifconfig
  attr_reader :ip, :media, :mediaopt, :description, :dhcp, :conf
  attr_writer :ip, :media, :mediaopt, :description

  def initialize(iface = "")
    unless iface.to_s.empty?
      case iface
      when /^tunnel/ then @conf = IfconfigTunnel.new(iface)
      else @conf = IfconfigPhysical.new(iface)
      end
    end
  end

  # List all available interfaces
  def interfaces
    iflist = `ifconfig | egrep "^[a-z0-9]+:" | awk '{print $1}' | sed 's/://'`.split
    interfaces = Hash.new
    interfaces['carp'] = []; interfaces['logical'] = []; interfaces['pfsync'] = []; interfaces['tunnel'] = []
    interfaces['vlan'] = []; interfaces['trunk'] = []; interfaces['physical'] = []

    iflist.each do |interface|
      ifconfig = `ifconfig #{interface}`
      iface = Hash.new
      iface['ip'] = Array.new
      iface['name'] = interface

      ifconfig.each do |line|
        case
        when line =~ /flags=\d+\<(.*)\>\s+mtu\s+([0-9]+)/
          iface['mtu'] = $2
          iface['flags'] = $1.split(",")
          iface["up?"] = iface['flags'].to_a.include?("UP") ? "up" : "down"
        when line =~ /^\s*media:\s+(.*)/
          iface['media'] = $1
        when line =~ /lladdr\s+(.*)/
          iface['lladdr'] = $1
        when line =~ /description: (.*)/
          iface['description'] = $1
        when line =~ /^\s+inet ([0-9\.]+) netmask ([0-9\.a-fx]+) broadcast ([0-9\.])/
          ip_address = $1
          broadcast = $3
          $2 =~ /(0x..)(..)(..)(..)/
          netmask = $1.hex.to_s + "." + $2.hex.to_s + "." + $3.hex.to_s + "." + $4.hex.to_s
          
          # Add a nice (dhcp) tag if the address has been given using dhcp
          ip_address += " (dhcp)" if `ps -ax | egrep "dhclient: #{iface['name']} " | grep -v grep | wc -l`.to_i > 0
          iface['ip'] << { "address" => ip_address, "netmask" => netmask, "broadcast" => broadcast }
        end
      end

      case iface['name']
      when /^carp/                  then interfaces['carp']    << iface
      when /^(tun|gif)/             then interfaces['tunnel']  << iface
      when /^(enc|pflog|lo)[0-9]+/  then interfaces['logical'] << iface
      when /^pfsync/                then interfaces['pfsync']  << iface
      when /^vlan/                  then interfaces['vlan']    << iface
      when /^trunk/                 then interfaces['trunk']   << iface
      else interfaces['physical'] << iface
      end
    end
    interfaces
  end

  def dhcp=(value)
    if value == true
      @dhcp = true
      unset @ip
    elsif value == false
      @dhcp = false
      @ip = Array.new
    end
  end

end

class IPAddress
  attr_reader :address, :netmask, :broadcast, :id

  def initialize(options = {})
    @id = options['id']
    @address = options['address']
    @netmask = options['netmask']
    @broadcast = options['broadcast']
  end

  def validate
    validate_as_ip(@address)
    validate_as_ip(@netmask)
    validate_as_ip(@broadcast) if @broadcast
  end

  def address=(addr)
    @address=addr if validate_as_ip(addr)
  end

  def netmask=(addr)
    @netmask=addr if validate_as_ip(addr)
  end

  def address=(addr)
    @broadcast=addr if validate_as_ip(addr)
  end

  def validate_as_ip(address)
    raise "invalid address" unless (address =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/)
    address.split(".").each {|n| raise "invalid address" unless n.to_i.between?(0,255) }
  end

end


class IfconfigPhysical
  attr_reader :media, :mediaopt, :description, :dhcp, :name, :available_media, :ip, :netmask, :default_route, :error
  attr_writer :media, :mediaopt, :description, :dhcp, :name, :ip, :netmask, :default_route

  def initialize(ifname)
    config = Hash.new
    @dhcp = false
    @status = "up"
    @available_media = [["default", ""]]
    @available_media += `ifconfig -m #{ifname} | egrep "media " | sed 's/\t*media\s*//'`.split("\n")
    if File.exist?("/etc/mygate")
      @default_route = File.open("/etc/mygate").read.strip
    else
      @default_route = ""
    end

    raise "no such interface" unless `ifconfig | egrep "^[a-z]+[0-9]+:" | awk '{print $1}' | sed 's/://'`.include? ifname
    File.open("/etc/hostname.#{ifname}").read.each_line do |line|
      next if line =~ /\s*#/  # Don't parse comments
  
      if line =~ /media ([a-zA-Z0-9]+ mediaopt [a-zA-Z0-9-_]+)/ or line =~ /media ([a-zA-Z0-9]+)/
        @media = $1
        @media = "autoselect" if @media =~ /^auto/ || @media.blank?
      end
      if line =~ /description \"(.*)\"/ or line =~ /description ([a-zA-Z0-9_]+)/
        @description = $1
      end
      if line =~ /\s+up[\s\n]/
        @status = "up"
      end
      if line =~ /\s+down[\s\n]/
        @status = "down"
      end
      if line =~ /\s+mtu ([0-9]+)/
        @mtu = $1
      end

      # Read IP address settings
      if line =~ /inet ([0-9\.]+) ([0-9\.]+) ([0-9\.]+|NONE)/
        @ip = $1
        @netmask = $2
      elsif line =~ /inet ([0-9\.]+) ([0-9\.]+)/
        @ip = $1
        @netmask = $2
      elsif line =~ /dhcp/
        @dhcp = true
      end
    end
    @name = ifname    
  end

  def attributes=(options = {})
    @media = options["media"].strip
    if options['dhcp'] == "true"
      @dhcp = true
      @ip = ""
      @netmask = ""
      @default_route = ""
    else
      @dhcp = false
      @ip = options["ip"].strip
      @netmask = options["netmask"].strip
      @default_route = options["default_route"].strip
    end
  end

  def valid?
    @error = Array.new
    unless @dhcp
      raise "Not Saved! IP address cannot be empty" if @ip.empty?
      raise "Not Saved! Netmask cannot be empty" if @netmask.empty?
      raise "Not Saved! Default route cannot be empty" if @default_route.empty?
      raise "Not Saved! Invalid address" unless @default_route =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
      @default_route.split(".").each {|n| raise "invalid address" unless n.to_i.between?(0,255) }
    end
    true
  end

  def save
    if self.valid?
      output = String.new
      media = " media #{@media}" unless @media.empty?
      if @dhcp
        output = "dhcp NONE NONE NONE" + media.to_s + "\n"
      else
        output = "inet #{@ip} #{@netmask} NONE" + media.to_s + "\n"
      end
      File.open("/etc/hostname.#{@name}", "w") {|f|
        f.puts output
      }
      File.open("/etc/mygate", "w") do |f|
        f.puts @default_route
      end
      RAILS_DEFAULT_LOGGER.info %x{/bin/sh /etc/netstart #{@name}}
      if @dhcp
        RAILS_DEFAULT_LOGGER.info %x{rm /etc/mygate}
      else
        RAILS_DEFAULT_LOGGER.info %x{route delete default; route add default #{@default_route}}
      end
      return true
    else
      return false
    end
  end

end
