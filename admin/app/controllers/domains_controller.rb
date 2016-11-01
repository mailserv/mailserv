class DomainsController < ApplicationController

  active_scaffold :domains do |config|
    config.columns = [:name, :quota, :quotamax]
    config.actions.swap :search, :live_search
    config.list.per_page = 200
    config.show.link.label = "Manage"
    config.show.link.page = true
    config.columns[:name].label = "Domain"
    config.columns[:quota].label = "Default Quota"
    config.columns[:quota].description = "MB. If no quota is set when adding a user, this is what will be set"
    config.columns[:quotamax].label = "Max Allowed Quota"
    config.columns[:quotamax].description = "MB. The maximum quota a user can get in this domain."

    config.create.columns.exclude :id
    config.update.columns.exclude :id
  end

  def show
    if @domain = Domain.find(params[:id]) rescue false
      @users = @domain.users
      @forwardings = @domain.forwardings
      @domain_admins = @domain.admins
    else
      flash[:error] = "No such domain"
      redirect_to :action => 'index'
    end
  end

  def add_domain_admin
    @domain = Domain.find(params[:id])
    @domain_admins = @domain.admins
    if @domain_admin = User.find_by_email(params[:admin][:address])
      @domain_admins << @domain_admin
    end
  end

  def delete_domain_admin
  end

end
