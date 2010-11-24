namespace :mailserver do
  
  task :load_hostconfig => [:environment] do
    h = Hostconfig.first || Hostconfig.new
    h = Hostconfig.new

    # Hostname
    h.hostname = File.read("/etc/myname").strip
    h.hostname = %x{hostname} if h.hostname.blank?
    
    # Interfaces
    h.interfaces = {}
    Hostconfig.available_interfaces.each do |iface|
      if config = File.read("/etc/hostname.#{iface}") rescue false
        if config.match(/dhcp/i)
          h.interfaces[iface.to_sym] = {:dhcp => true}
        else
          ip, netmask = config.match(/inet\s+\b([\w\.]+)\s+\b([\w\.]+)/)[1,2]
          h.interfaces[iface.to_sym] = {:dhcp => false, :ip => ip, :netmask => netmask}
        end
      else
        ip, netmask = %x{ifconfig #{iface} | grep "inet "}.match(/inet\s+\b([\w\.]+).*netmask\s+\b([\w\.]+)/)[1,2]
        netmask =~ /(0x..)(..)(..)(..)/
        netmask = $1.hex.to_s + "." + $2.hex.to_s + "." + $3.hex.to_s + "." + $4.hex.to_s
        h.interfaces[iface.to_sym] = {:dhcp => false, :ip => ip, :netmask => netmask}
      end
    end
    
    # Certificates
    h.certificate = File.read("/etc/ssl/server.crt")
    h.certificate_key = File.read("/etc/ssl/private/server.key")
    puts h.to_yaml
  end
  
end