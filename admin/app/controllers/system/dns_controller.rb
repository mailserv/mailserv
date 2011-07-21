class System::DnsController < ApplicationController

  def index
    begin
      @dns = ResolvConf.new
      logger.debug "#{@dns.inspect}"
      if params["commit"]
        @dns.attributes = params
        @dns.save
        flash[:notice] = "Saved successfully"
      end
    rescue
      flash[:error] = $!
    end
  end

end
