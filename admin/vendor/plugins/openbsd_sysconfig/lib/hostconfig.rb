require 'tempfile'
class Hostconfig
  attr_accessor :hostname, :domain

  def initialize
    @hostname = String.new
    @domain = String.new
    myname = %x{hostname}.strip
    if myname =~ /([a-zA-Z0-9_-]+)\.(.*)/
      @hostname = $1
      @domain = $2
    elsif myname =~ /(.*)/
      @hostname = $1
    end
  end

  def attributes=(params = {})
    @hostname     = params["hostname"].to_s.strip
    @domain       = params["domain"].to_s.strip
  end

  def valid?
    !@hostname.blank?
  end

  def save
    if self.valid?
      hostname = @hostname
      hostname += "." + @domain unless @domain.blank?
      tf = Tempfile.new("_myname")
      tf.puts hostname
      tf.close
      %x{
        sudo install -m 644 #{tf.path} /etc/myname
        sudo hostname #{hostname}
      }
      true
    else
      false
    end
  end

end
