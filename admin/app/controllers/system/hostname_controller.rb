class System::HostnameController < ApplicationController

  def index
    begin
      @hostname = Hostconfig.new
      if params[:hostname]
        @hostname.attributes = params[:hostname]
        if @hostname.save
          sysrake "system:reload_certificate_hostname"
          flash[:notice] = "Hostname successfully updated. Services are being reloaded with new hostname."
        end
      end
    rescue
      flash[:error] = $!
    end
  end

end
