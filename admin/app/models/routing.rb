class Routing < ActiveRecord::Base
  validates_presence_of :destination, :transport
  validates_uniqueness_of :destination
  validates_format_of :destination, :with => /[a-zA-Z0-9\-_\.\*]+/
  
  def validate
    if transport =~ /^smtp\:(.*)/
      ip_or_dest = $1
      if ip_or_dest =~ /^[0-9\.\:]+$/
        errors.add(:transport, "need a valid ip address") unless ip_or_dest =~ /^(\d{1,3}\.){3}\d{1,3}$/
      else
        errors.add(:transport, "need a valid domain name") unless ip_or_dest =~ /[a-zA-Z0-9\-_.]+/
      end
    end
  end

end
