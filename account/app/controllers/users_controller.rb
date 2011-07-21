class UsersController < ApplicationController
  before_filter :check_admin
  before_filter :find_domain

  active_scaffold :user do |config|
    config.columns = [:id, :name, :fullname, :email, :quota, :password1, :password1_confirmation]
    config.list.columns.exclude :password1, :password1_confirmation
    config.list.per_page = 20

    config.actions = [:live_search, :create, :update, :list, :delete]
    config.action_links.add 'upload', :label => "Import CSV", :type => :table, :inline => true 

    config.columns[:admin_for].label = "Domain Admin for"
    config.columns[:password1].label = "Password"
    config.columns[:password1_confirmation].label = "Confirm Password"
    config.columns[:quota].description = "MB"
    columns[:password1].form_ui = :password
    columns[:password1_confirmation].form_ui = :password
    config.create.columns.exclude :id, :email
    config.update.columns.exclude :id, :email
  end

  def find_domain
    @domain = Domain.find(params[:domain_id])
    unless current_user.admin_for.include?(@domain)
      flash[:error] = "You are not admin for this domain"
      redirect_to :controller => 'domains', :action => 'index'
    end
  end

  def check_admin
    if current_user.admin_for.count.zero?
      flash[:error] = "You are not admin"
      redirect_to :controller => 'antispam'
    end
  end

  def upload
    render :partial => "upload"
  end

  def import
    new_devs = csv_to_array_of_thing_hashes(params[:csv_file].read)

    imported = 0
    new_devs.each_pair do |k, thing|
      unless thing[:name].blank?
        user = User.new(thing)
        user.domain_id = @domain.id
        imported += 1 if user.save
      end
    end
    if imported.zero?
      flash[:notice] = "Nothing imported"
    else
      flash[:notice] = "Successfully imported #{imported} users"
    end
    redirect_to :controller => 'domains', :action => 'show', :id => @domain.id
  end

  private

  def csv_to_array_of_thing_hashes(data)
    data = data.gsub('"','')
    things = {}
    csv = FasterCSV.new(data, :headers => true)
    csv.each do |row|
      thing = {}
      row.to_hash.each_pair do |k,v|
        k = k.to_sym
        thing.store(k,v)
        things[thing[:name]] = thing
      end
    end
    return things
  end

end
