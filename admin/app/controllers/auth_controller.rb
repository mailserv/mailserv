class AuthController < ApplicationController
  layout nil
  skip_before_filter :authenticate

  def login
    if request.post?
      reset_session # Make sure everything is cleared up before logging in
      if admin = Admin.authenticate(params[:admin][:username], params[:admin][:password])
        session[:admin_id] = admin.id
        redirect_to :controller => 'dashboard'
      else
        flash[:error] = "Incorrect username or password"
        redirect_to :action => 'index'
      end
    else
      redirect_to root_path
    end
  end

  def logout
    session[:admin] = nil
    reset_session
    redirect_to root_path
  end

end
