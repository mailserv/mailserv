class ApplicationController < ActionController::Base
  before_filter :preflight_check
  include ExceptionNotification::Notifiable

  def authenticate
    request.env["HTTPS"] = "on"
    redirect_to "/", :only_path => true	unless session[:user]
  end

  def preflight_check
#    request.relative_url_root = "/account"
    request.env["HTTPS"] = "on" if request.env["HTTP_REFERER"] =~ /^https/
  end

  def current_user
    @current_user ||= User.find(session[:user])
  end

  def default_url_options(options = nil)
    { :protocol => "https" }
  end

end
