class ResolvConf
  require 'resolv'
  require 'timeout'
  attr_reader :nameservers, :domain, :lookup, :search
  attr_writer :nameservers, :domain, :lookup, :search
  
  def initialize
    @nameservers = Array.new
    @lookup = String.new
    @search = String.new
    @resolv_conf = "/etc/resolv.conf"
  
    if File.exist?(@resolv_conf)
      File.open(@resolv_conf).read.each_line{|line|
        case
        when line =~ /^nameserver\s+(.*)/
          @nameservers << $1
        when line =~ /^domain\s+(.*)/
          @search = $1
        when line =~ /^search\s+(.*)/
          @search = $1
        end
      }
    end
  end
  
  def valid?
    raise "resolv.conf needs at least one nameserver" if @nameservers.empty?
    true
  end

  def attributes=(params = {})
    @nameservers = Array.new
    @lookup = Array.new
    @search = params["search"].to_s.strip
    params["nameservers"].each_value do |ns|
      @nameservers << ns unless ns.empty?
    end
  end

  def save
    self.valid?
    output = String.new
    @nameservers.each {|nameserver|
      output += "nameserver #{nameserver}\n" unless nameserver.to_s.strip.empty?
    }
    output += "search #{@search}\n" unless @search.empty?
    output += "lookup file bind\n"
    File.open(@resolv_conf, "w") {|f|
      f.puts(output)
    }
  end

  def check_servers
    begin
      @nameservers.each do |nameserver|
        timeout(10) do
          Resolv::DNS.new({:nameserver => ["1.1.1.1"]}).getaddress("dnstest.allard.nu")
        end
      end
      true
    rescue
      false
    end
  end

end
