module ApplicationHelper

  def current_user
    @current_user ||= User.find(session[:user])
  end

  def page_id
    if controller.action_name == "index"
      controller.controller_name
    else
      controller.controller_name + "_" + controller.action_name
    end
  end

end
