module ApplicationHelper

  def current_user
    @current_user ||= Admin.find(session[:admin_id])
  end

  def system_info
    @system_info ||= System.new
  end

  def page_title
    "#{controller.controller_name.gsub(/_/,' ').capitalize} | #{CONF['product'].capitalize} Admin"
  end

  def page_id
    if controller.action_name == "index"
      controller.controller_name
    else
      controller.controller_name + "_" + controller.action_name
    end
  end

  def display_version_info
    out = ""
    if !system_info.activated?
      out += link_to( "No license installed, click here to install license", :controller => 'system/activate' )
    else
      out += "Appliance is licensed, thank you"
    end
    return out
  end

  def application_javascript_tag
    name = controller.controller_name
    javascript_include_tag "#{name}" if File.exists? File.join(Rails.root, "public", "javascripts", "#{name}.js")
  end

  def application_stylesheet_tag
    name = controller.controller_name
    stylesheet_link_tag "#{name}" if File.exists? File.join(Rails.root, "public/stylesheets", "#{name}.css")
  end

end
