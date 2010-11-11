class ApplicationController < ActionController::Base
  layout proc{ |c| c.request.xhr? ? false : "application" }

  before_filter :https_check
  before_filter :authenticate

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery

  rescue_from ActionController::InvalidAuthenticityToken, :with => :session_expired

  private

  def authenticate
    unless session[:admin_id]
      # If there's no session recorded, the user isn't logged in so
      # we redirect the user to the login page.
      session['return_to'] = request.request_uri
      flash[:error] = 'You are not logged in! Please Log in first.'
      redirect_to root_path
      return false
    end
  end

  def session_expired
    flash[:notice] = "Session has expired."
    redirect_to logout_path
  end

  def current_user
    @current_user ||= Admin.find(session[:admin_id])
  end

  def system_info
    @system_info ||= System.new
  end

  def default_url_options(options = nil)
    { :protocol => "https" } if Rails.env == "production"
  end

  def https_check
    request.env["HTTPS"] = "on" unless request.remote_ip.to_s == "127.0.0.1"
  end

  def sysrake(task, options = {})
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'"}
    logger.info "/usr/local/bin/mailserv #{task} #{args.join(' ')} &"
    system "/usr/local/bin/mailserv #{task} #{args.join(' ')} &"
  end

end
