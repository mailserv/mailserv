#!/usr/local/bin/ruby

# Exit if there's already an interface address set
exit if %x{ifconfig | grep "inet " | grep -v "127.0.0.1" | wc -l}.to_i > 0

def check(ip)
  %x{ping -c 3 #{ip} >/dev/null 2>&1; echo $?}.to_i.zero?
end

def ask
  print "IP address: "
  @ip = gets.strip
  print "Netmask: "
  @mask = gets.strip
  print "Default gateway: "
  @gateway = gets.strip
end

def set(interface,ip,mask,gateway)
  %x{
    ifconfig #{interface} inet #{ip} netmask #{mask}
    route add default #{gateway} 2>/dev/null
  }
end

def write(interface,ip,mask,gateway)
  %x{
    echo "inet #{ip} #{mask} NONE" > /etc/hostname.#{interface}
    echo "#{gateway}" > /etc/mygate
  }
end

interface = %x{ifconfig | egrep "BROADCAST" | awk '{print $1}' | sed 's/://'}.split[0]

puts "\n---------------------------------------------------------------------\n"
puts "No DHCP server could be found, please enter network details manually.\n"

ask
set(interface,@ip,@mask,@gateway)

puts "pinging default gateway to test connectivity..."
if check(@gateway)
  puts "success, writing configuration.\n"
else
  puts "\nCould not ping #{@gateway}, are you sure the config is correct(y/n) "
  response = gets.strip
  while response.match(/^[yY]/).nil?
    ask
    set(interface,@ip,@mask,@gateway)
    puts "pinging default gateway to test connectivity..."
    if check(@gateway)
      puts "success, writing configuration.\n"
      response = "y"
    else
      puts "\nCould not ping #{@gateway}, are you sure the config is correct(y/n) "
      response = gets.strip
    end
  end
end
write(interface,@ip,@mask,@gateway)

puts "\nNetwork configuration has been set\n"
puts "---------------------------------------------------------------------\n"

