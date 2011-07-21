class Timezone
  attr_reader :citycodes, :city, :locality
  attr_writer :city, :country, :locality

  def initialize
    @country, @city, @locality = readlink
  end

  def countries
    zone = Sudo.ls("/usr/share/zoneinfo/").split
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
    if Sudo.directory?("/usr/share/zoneinfo/#{@country}/")
      Sudo.ls("/usr/share/zoneinfo/#{@country}/").split
    else
      []
    end
  end

  def city
    readlink[1]
  end

  def localities
    if @city && Sudo.directory?("/usr/share/zoneinfo/#{@country}/#{@city}")
      Sudo.ls("/usr/share/zoneinfo/#{@country}/#{@city}").split
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
    Sudo.rm("/etc/localtime")
    if locality.blank? && @city.blank?
      Sudo.ln_s("/usr/share/zoneinfo/#{@country}", "/etc/localtime")
    elsif locality.blank?
      Sudo.ln_s("/usr/share/zoneinfo/#{@country}/#{@city}", "/etc/localtime")
    else
      Sudo.ln_s("/usr/share/zoneinfo/#{@country}/#{@city}/#{@locality}", "/etc/localtime")
    end
  end

  private

  def readlink
    if Sudo.symlink?("/etc/localtime")
      Sudo.readlink("/etc/localtime").gsub(/.*zoneinfo\//, "").split(/\//)
    else
      ["GMT"]
    end
  end

end
