module GettingStartedHelper

  def display_ip_addresses(ips)
    output_string = ""
    ips.each do |ip|
      output_string += ip['address'].to_s + "<br />"
    end
    output_string
  end

  def display_netmasks(ips)
    output_string = ""
    ips.each do |ip|
      output_string += ip['netmask'].to_s + "<br />"
    end
    output_string
  end

  def ip_address_field(bool)
    if bool
      text_field "interface", "ip", {:size => 15, :maxlength => 15, :disabled => 'disabled' }
    else
      text_field "interface", "ip", {:size => 15, :maxlength => 15 }
    end
  end

  def netmask_field(bool)
    if bool
      text_field "interface", "netmask", {:size => 15, :maxlength => 15, :disabled => 'disabled' }
    else
      text_field "interface", "netmask", {:size => 15, :maxlength => 15 }
    end
  end

  def default_route_field(bool)
    if bool
      text_field "interface", "default_route", {:size => 15, :maxlength => 15, :disabled => 'disabled' }
    else
      text_field "interface", "default_route", {:size => 15, :maxlength => 15 }
    end
  end

  def ntpserver_is_pool?(type)
    " checked=\"checked\"" if type == "servers"
  end

end
