class Timezone
  attr_reader :citycodes, :city, :locality
  attr_writer :city, :country, :locality

  def initialize
    @country, @city, @locality = readlink
  end

  def readlink
    if File.symlink?("#{FILESYS_ROOT}/etc/localtime")
      File.readlink("#{FILESYS_ROOT}/etc/localtime").gsub(/.*zoneinfo\//, "").split(/\//)
    end
  end

  def countries
    zone = %x{ls #{FILESYS_ROOT}/usr/share/zoneinfo/}.split
    zone.delete("posixrules")
    zone.delete("zone.tab")
    zone.delete("iso3166.tab")
    zone.delete("+VERSION")
    zone
  end

  def country=(country)
    @country = country
  end

  def country
    readlink[0]
  end

  def cities
    if File.directory?("#{FILESYS_ROOT}/usr/share/zoneinfo/#{@country}/")
      %x{ls #{FILESYS_ROOT}/usr/share/zoneinfo/#{@country}/}.split
    else
      []
    end
  end

  def city
    readlink[1]
  end

  def localities
    if @city && File.directory?("#{FILESYS_ROOT}/usr/share/zoneinfo/#{@country}/#{@city}")
      %x{ls #{FILESYS_ROOT}/usr/share/zoneinfo/#{@country}/#{@city}}.split
    else
      []
    end
  end

  def locality
    readlink[2]
  end

  def attributes=(attributes)
    @country = attributes["country"]
    @city = attributes["city"]
    @locality = attributes["locality"]
  end

  def save
    %x{rm #{FILESYS_ROOT}/etc/localtime}
    if @locality.blank? && @city.blank?
      %x{cd #{FILESYS_ROOT}/etc && ln -s ../usr/share/zoneinfo/#{@country} localtime}      
    elsif @locality.nil?
      %x{cd #{FILESYS_ROOT}/etc && ln -s ../usr/share/zoneinfo/#{@country}/#{@city} localtime}
    else
      %x{cd #{FILESYS_ROOT}/etc && ln -s ../usr/share/zoneinfo/#{@country}/#{@city}/#{@locality} localtime}
    end
  end

end