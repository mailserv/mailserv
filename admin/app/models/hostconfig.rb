class Hostconfig < ActiveRecord::Base
  serialize :interfaces, Hash
  serialize :routes, Hash
  serialize :nameservers
  serialize :ntpservers
  
  def self.available_interfaces
    out = %x{ifconfig -a}.map {|l| l.match(/^\b([\w]+)/)[1] rescue nil}.compact
    out.delete("enc0")
    out.delete("pflog0")
    out.delete("lo0")
    out
  end
  
end
