class UsersController < ApplicationController
  before_filter :find_domain

  active_scaffold :user do |config|
    config.columns = [:id, :name, :fullname, :email, :quota, :admin_for, :password1, :password1_confirmation]
    config.list.columns.exclude :password1, :password1_confirmation
    config.update.columns.exclude :admin_for
    config.create.columns.exclude :admin_for
    config.list.per_page = 20

    config.actions = [:show, :live_search, :create, :update, :list, :delete]
    config.action_links.add 'upload', :label => "Import CSV", :type => :table, :inline => true 

    config.show.link.label = "Domain Admin"
    config.show.label = ""

    config.columns[:admin_for].label = "Domain Admin for"
    config.columns[:password1].label = "Password"
    config.columns[:password1_confirmation].label = "Confirm Password"
    config.columns[:quota].description = "MB"
    columns[:password1].form_ui = :password
    columns[:password1_confirmation].form_ui = :password
    config.create.columns.exclude :id, :email
    config.update.columns.exclude :id, :email
  end

  def show
    @user = User.find(params[:id])
    @domains = Domain.all
    @user.admin_for.each {|d| @domains.delete(d)}
  end

  def save_admin_domains
    user = User.find(params[:id])
    user.admin_for = []
    params[:domains].to_a.each do |domain_id|
      user.admin_for << Domain.find(domain_id)
    end
    redirect_to "/domains/#{params[:domain_id]}"
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

  def find_domain
    @domain = Domain.find(params[:domain_id])
  end

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
