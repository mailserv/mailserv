class DomainsController < ApplicationController
  before_filter :check_admin

  def index
    redirect_to :controller => "domains", :action => 'show', :id => current_user.admin_for[0].id
  end

  def show
    begin
      @domain = Domain.find(params[:id])
      unless current_user.admin_for.include?(@domain)
        flash[:error] = "You are not admin for this domain"
        redirect_to :controller => 'domains', :action => 'index'
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to :controller => 'domains', :action => 'index'
    end
  end

  def change
    redirect_to :controller => "domains", :action => 'show', :id => params[:domain][:id]
  end

  private

  def check_admin
    if current_user.admin_for.count.zero?
      flash[:error] = "You are not admin"
      redirect_to :controller => 'antispam'
    end
  end

end
