class PostfixMynetworks
  require 'ipaddr'
  attr_accessor :networks
  attr_reader :errors, :error_messages

  def initialize
    @networks = get_mynetworks
  end

  def valid?
    @errors = false
    @error_messages = Array.new
    @networks.each do |network|
      return false unless valid_cidr?(network)
    end
    true
  end

  def save
    unless valid?
      return false
      break
    end
    %x{
      /usr/local/sbin/postconf -e mynetworks="127.0.0.0/8 #{@networks.join(' ')}"
      /usr/local/sbin/postfix reload 2>/dev/null
    }
    true
  end

  private

  def get_mynetworks
    mynetworks = %x{/usr/local/sbin/postconf -h mynetworks}.split(/[,\s]/)
    mynetworks.delete("127.0.0.0/8")
    mynetworks
  end

  def valid_cidr?(cidr)
    begin
      cidr =~ /(.*)\/(.*)/
      addr = $1 ? $1 : cidr
      netsize = $2
      unless addr == IPAddr.new(cidr).to_s
        @errors = true
        @error_messages << "#{cidr} is not a valid CIDR block, you might meant to enter " + IPAddr.new(cidr).to_s
        return false
      end
      true
    rescue
      @errors = true
      @error_messages << "#{cidr} is invalid"
      false
    end
  end

end
