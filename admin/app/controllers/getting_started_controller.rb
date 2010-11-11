class GettingStartedController < ApplicationController
  layout "not_logged_in"
  before_filter :authorize
  skip_before_filter :authenticate

  def index
    redirect_to :action => "step1"
  end

  def step1 # Setting Hostname
    begin
      @hostname = Hostconfig.new
      if params[:hostname]
        @hostname.attributes = params[:hostname]
        if @hostname.save
          flash[:notice] = "Generating certificates, you will get a warning if the hostname has changed."
          redirect_to :action => "step2"
        end
      end
    rescue
      flash[:error] = $!
    end
  end

  def step2 # Time and TimeZone
    @timezone = Timezone.new
    @ntp = Ntp.new
    begin
      if request.post?
        @timezone.attributes = params[:timezone]

        if @timezone.save
          date = params[:date]["year"] + params[:date]["month"].rjust(2,"0") + params[:date]["day"].rjust(2,"0")
          time = params[:date]["hour"].rjust(2,"0") + params[:date]["minute"].rjust(2,"0")
          Sudo.exec "date #{date}#{time}"
          reset_session
          flash[:notice] = "Saved successfully"
          redirect_to :action => 'step3'
        end
      end
    rescue
      flash[:error] = $!
      redirect_to :action => 'step2'
    end
  end

  def step3 # Network & DNS
    begin
      @interface = Ifconfig.new(Ifconfig.new.interfaces["physical"][0]["name"]).conf
      @dns = ResolvConf.new
      if request.post?
        @dns.attributes = params
        @dns.save

        @interface.attributes = params[:interface]
        if @interface.save
          flash[:notice] = "Saved successfully"
          redirect_to :action => "step4"
        end
      end      
    rescue
      flash[:error] = $!
      redirect_to :action => 'step3'
    end
  end

  def step4 # Admin User
    @admin = Admin.new
    if request.post?
      @admin = Admin.new
      @admin.attributes = params[:admin]
      if @admin.save
        flash[:notice] = "Getting Started finished Successfully. You can now login to the appliance."
        redirect_to root_url
      end
    end
  end

  def timezone_change_country
    @timezone = Timezone.new
    @timezone.country = params["country"]
    @timezone.locality = ""
    render :partial =>  'timezone_cities', :object => @timezone.cities
  end

  def timezone_change_locality
    @timezone = Timezone.new
    @timezone.country = params["country"]
    @timezone.city = params["city"]
    render :partial => 'timezone_localities', :object => @timezone.localities
  end

  private

  def authorize
    unless Admin.count.zero? || Rails.env == "development"
      flash[:error] = "Getting Started can only run if no admins has been configured"
      redirect_to root_url
    end
  end

end
