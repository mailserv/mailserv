#!/usr/local/bin/ruby
$stdout.sync = true
require 'rubygems'
require 'highline/import'

trap("INT") { puts "\n" }
trap("TSTP") {puts ""}

def fresh_install?
  %x{/var/www/admin/script/runner -e production 'puts Admin.count'}.to_i.zero?
end

def unlicensed?
  %x{/var/www/admin/script/runner -e production 'puts License.count'}.to_i.zero?
end

def ask_passwords
  pass1 = ask("Password:  ") do |q|
    q.echo = "*"
    q.validate = /^(\w{6,31})$/
    q.responses[:not_valid] = "Please use a stronger password (min 6 characters)"
  end
  pass2 = ask("Password Confirm:  ") {|q| q.echo = "*" }

  while pass1 != pass2
    say "\nPasswords don't match"
    pass1 = ask("Password:  ") do |q|
      q.echo = "*"
      q.validate = /^(\w{6,31})$/
      q.responses[:not_valid] = "Please use a stronger password (min 6 characters)"
    end
    pass2 = ask("Password Confirm:  ") {|q| q.echo = "*" }
  end
  return pass1
end

def my_ip(interface = nil)
  interface = %x{ifconfig | egrep "BROADCAST" | awk '{print $1}' | sed 's/://'}.split[0] unless interface
  %x{ifconfig #{interface} | grep "inet " | awk '{print $2}'}.strip
end

def my_netmask(interface)
  nm = %x{ifconfig #{interface} | grep "inet " | awk '{print $4}'}.strip
  if nm =~ /0x[a-f0-9]{8}/
    eval("0x#{nm[2..3]}").to_s + "." + eval("0x#{nm[4..5]}").to_s + "." + eval("0x#{nm[6..7]}").to_s + "." + eval("0x#{nm[8..9]}").to_s
  else
    nil
  end
end

def my_gw
  %x{netstat -rn -f inet | grep default | awk '{print $2}'}.strip
end

def my_dns
  %x{cat /etc/resolv.conf | grep nameserver | head -1 | awk '{print $2}'}.strip
end

def my_hostname
  %x{hostname}.strip.match(/([\w\-]+)/)[1] || "mailserv"
end

def my_domain
  %x{hostname}.strip.match(/[\w\-]+\.([\w\-\.]+)/)[1]
end

def hostconfig
  begin
    hostname = ask("Hostname: ", String) do |q|
      q.default = lambda { my_hostname }.call
      q.validate = /^([\w\-]+)$/
      q.responses[:not_valid] = "Please enter the hostpart only (i.e. mail out of mail.example.com)."
    end

    domain = ask("Domain: ", String) do |q|
      q.default = lambda { my_domain }.call
      q.validate = /^([\w\-\.]+)$/
      q.responses[:not_valid] = "Please enter the hostpart only (i.e. example.com out of mail.example.com)."
    end

    say "\n#{hostname}.#{domain}\n\n"

  end while !agree("Is this correct?  ", true)
  File.open("/etc/myname", "w") do |f|
    f.puts "#{hostname}.#{domain}"
  end
  %x{
    hostname #{hostname}.#{domain}
    /usr/local/bin/mailserv system:reload_certificate_hostname
  }
end

def setup_ip
  interface = %x{ifconfig | egrep "BROADCAST" | awk '{print $1}' | sed 's/://'}.split[0]
  
  if agree("Do you want to use DHCP?  ", true)
    File.open("/etc/hostname.#{interface}", "w") do |f|
      f.puts("dhcp NONE NONE NONE")
    end
    say %x{/bin/sh /etc/netstart #{interface}}
  else
    begin
      entry = {}

      entry[:ip] = ask( "IP address: ", String) do |q|
        q.default = lambda { my_ip(interface) }.call
        q.validate = /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
        q.responses[:not_valid] = "Please enter a valid IP address."
      end

      entry[:mask] = ask( "Netmask: ", String) do |q|
        q.default = lambda { my_netmask(interface) }.call
        q.validate = /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
        q.responses[:not_valid] = "Please enter a valid netmask."
      end

      entry[:gw] = ask( "Default Gateway: ", String) do |q| 
        q.default = lambda { my_gw }.call
        q.validate = /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
        q.responses[:not_valid] = "Please enter a valid netmask."
      end

      entry[:dns] = ask( "DNS Server: ", String) do |q| 
        q.default = lambda { my_dns }.call
        q.validate = /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
        q.responses[:not_valid] = "Please enter a valid IP address for the DNS server."
      end

    end while !agree("Is this correct?  ", true)

    File.open("/etc/hostname.#{interface}", "w") do |f|
      f.puts("inet #{entry[:ip]} #{entry[:mask]} NONE")
    end
    %x{ifconfig #{interface} inet #{entry[:ip]} netmask #{entry[:mask]}}

    File.open("/etc/resolv.conf", "w") do |f|
      f.puts("nameserver #{entry[:dns]}")
      f.puts("lookup file bind")
    end

    File.open("/etc/mygate", "w") do |f|
      f.puts(entry[:gw])
    end
    %x{route delete default; route add default #{entry[:gw]}}
  end
end

def add_admin
  begin
    username = ask("Username: ", String) do |q|
      q.validate = /^([a-zA-Z0-9\_\-]+)$/
      q.responses[:not_valid] = "Please use characters 'a-z, A-Z, 0-9, _-' only."
    end
    email = ask("Email (optional, will be used for status emails): ", String) do |q|
      q.validate = /(^([a-zA-Z0-9\_\-+]+@([a-zA-Z0-9\_\-\.]+))$|^$)/
      q.responses[:not_valid] = "Please enter a valid email address"
    end
    password = ask_passwords
  end while !agree("Is this correct?  ", true)
  %x{/var/www/admin/script/runner -e production 'Admin.create!(
    :username => "#{username}", :password => "#{password}", :email => #{email.size.zero? ? "nil" : "\"" + email + "\""})'}
end

def setup
  say "\n\n\n"
  say "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
  say "Host Configuration details:\n\n"
  hostconfig

  say "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
  say "IP Configuration details:\n\n"
  setup_ip

  say "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
  say "Add Administrator:\n\n"
  add_admin
end


if fresh_install?
  begin
    say "\n\n\n"
    say "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
    say "Please browse to: https://#{my_ip}:4200 to get started\n\n"
    say "Alternatively, type 'setup' on the command prompt\n\n"

    begin
      choose do |menu|
        menu.layout    = :menu_only
        menu.shell     = true
        menu.readline  = true

        menu.choice(:setup, "Getting Started configuration.") { setup }
        menu.choice(:quit,  "Exit from menu.") { @quit_from_menu = true }
      end
    rescue EOFError  # HighLine throws this if @input.eof?
      puts "\n"
    end
  end while fresh_install?
end

say "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
say "                Webadmin Interface: https://#{my_ip}:4200\n"
say "                 Webmail Interface: https://#{my_ip}\n"
say "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"

if unlicensed?
  say "Please login to the Webadmin Interface to setup users and domains.\n"
  say "\n"

  begin
    begin
      choose do |menu|
        menu.layout    = :menu_only
        menu.shell     = true
        menu.readline  = true

        menu.choice(:ping, "ping host") do |command, details|
          if details.strip.empty?
            print "\nUsage: ping host\n"
          else
            puts system("ping -c 3 '#{details}'")
          end
        end

        menu.choice(:hostconfig, "Change Host configuration details.") { hostconfig }
        menu.choice(:ipconfig, "Change IP configuration details.") { setup_ip }
        menu.choice(:shutdown, "Shutdown the system.") { %x{shutdown -h now} }
        menu.choice(:quit,  "Exit to login prompt.") { @quit_from_menu = true  }
      end
    rescue EOFError  # HighLine throws this if @input.eof?
      puts "\n"
    end
  end while @quit_from_menu.nil?
  say "\n\n"
  say "Unlicensed install. Console login disabled.\n"
  say "All Mailserv configurations available from the Webadmin Interface\n"
  say "\n"
end
