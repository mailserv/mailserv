class NetTest
  require 'timeout'
  require 'socket'

  def self.dns
    begin
      %x{cat /etc/resolv.conf | grep nameserver | awk '{print $2}'}.each do |nameserver|
        Timeout::timeout(2) do
          if nameserver.strip! =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
            Resolv::DNS.new({:nameserver => nameserver}).getaddress("dnstest.allardsoft.com")
          end
        end
      end
      true
    rescue Timeout::Error
      false
    end
  end

  def self.http
    begin
      Timeout::timeout(2) do
        %x{/usr/bin/nc -z update.allardsoft.com 80; echo $?}.to_i.zero?
      end
    rescue Timeout::Error
      false
    end
  end

  def self.https
    begin
      Timeout::timeout(2) do
        %x{/usr/bin/nc -z update.allardsoft.com 443; echo $?}.to_i.zero?
      end
    rescue Timeout::Error
      false
    end
  end

end
