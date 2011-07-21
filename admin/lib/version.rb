class Version
  attr_accessor :version

  def to_i
    @version =~ /([\d\.]+)/
    split_version = $1.to_s.split(".")
    (split_version[0].to_i * 10000) + (split_version[1].to_i * 100) + split_version[2].to_i
  end

  def to_s
    if @version =~ /v/
      @version
    else
      "v" + @version
    end
  end

  def long
    CONF["product"].capitalize + " " + (@version =~ /v/ ? @version : "v" + @version)
  end

  def initialize(version = "")
    unless version.blank?
      @version = version
    else
      @version = %x{cat /usr/local/share/#{CONF["product"]}/version}.strip
    end
  end

end
