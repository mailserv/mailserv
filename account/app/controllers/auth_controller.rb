class AuthController < ApplicationController

  def autologin
    if session[:user] = User.new.get_from_session(params[:id]).id
      if current_user.admin_for.count.zero?
        redirect_to :action => :unauthorized
      else
        redirect_to :controller => :domains
      end
    else
      flash[:error] = "Could not find user session"
      redirect_to "/"
    end
  end

  def logout
    session[:user] = nil
    redirect_to "/"
  end

end
