class System::TimeController < ApplicationController

  def index
    system_info.timezone = Timezone.new
    @timezone = system_info.timezone
    @ntp = Ntp.new
    if request.post?
      if params[:timezone]
        @timezone.attributes = params[:timezone]
        if @timezone.save
          flash[:notice] = "Saved successfully"
        end
      end
      if params[:ntp]
        @ntp.attributes = params[:ntp]
        @ntp.save
      end
      redirect_to :action => "index"
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

  def check_ntp
    if Ntp.test(params[:server])
      render :text => "<span style='color: green;'>ok</span>"
    elsif !params[:server].blank?
      render :text => "<span style='color: red'>err</span>"
    else
      render :text => ""
    end
  end

end
