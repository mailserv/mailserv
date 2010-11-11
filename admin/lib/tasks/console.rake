
desc "Displays the console startup message"
task :init_console => :environment do
  puts "\n\n\n\n\n\n\n\n\n\n\n\n\n"
  puts "--------------------------------------------------------------------------------\n"
  puts "Mailserver boot completed\n\n"

  if Admin.count.zero?
    if %x{ifconfig | grep "inet " | grep -v "127.0.0.1" | wc -l}.to_i.zero?
      %x{
        ifconfig #{interface} inet 192.168.0.1 netmask 255.255.255.0
        route delete default
      }
    end
    puts "An ip address of #{my_ip(interface)} has been set on interface #{interface}\n"
    puts "\n"
    puts "Do you want to set another ip manually (y/n) "
    response = STDIN.gets.strip
    if response.match(/^[yY]/)
      print "IP address: "
      @ip = STDIN.gets.strip
      print "Netmask: "
      @mask = STDIN.gets.strip
      print "Default gateway: "
      @gateway = STDIN.gets.strip
      set(interface,@ip,@mask,@gateway)
    end
    puts "\n"
    puts "================================================================================\n"
    puts "Please browse to https://#{my_ip(interface)}:4200 to complete the setup.\n"
    puts "\n"
    puts "The ip configuration screen will be presented on the console until the initial\n"
    puts "setup has completed\n"
    puts "================================================================================\n\n"
  end # End the Getting started setup

  if memory < 384
    puts "\n"
    puts "================================================================================\n"
    puts "Available memory: #{memory} Mb.\n"
    puts "\n"
    puts "Minimum memory requirement: 384 Mb\n"
    puts "Recommended memory for production systems: 512 Mb\n"
    puts "================================================================================\n\n"    
  end

  puts "Admin interface available on https://#{my_ip(interface)}:4200\n"
  puts "Webmail interface available on https://#{my_ip(interface)}\n\n"

  # Display the console message
  system = System.new
  if !License.first
    puts "Console access disabled until a license has been installed\n"
    puts "Root password is locked, please set in the web console\n" if System.root_is_locked?
  elsif !system.console_enabled? || System.root_is_locked?
    puts "Console access disabled, please enable in the web console\n" unless system.console_enabled?
    puts "Root password is locked, please set in the web console\n" if System.root_is_locked?
  end
  puts "--------------------------------------------------------------------------------\n"
end  


def my_ip(interface)
  %x{ifconfig #{interface} | grep "inet " | awk '{print $2}'}.strip
end

def set(interface,ip,mask,gateway)
  %x{
    ifconfig #{interface} inet #{ip} netmask #{mask}
    route delete default
    route add default #{gateway} 2>/dev/null
  }
end

def interface
  %x{ifconfig | egrep "BROADCAST" | awk '{print $1}' | sed 's/://'}.split[0]
end

def memory
  (%x{head /var/run/dmesg.boot  | grep "real mem" | awk '{print $4}'}.to_f / 1048576).round
end
