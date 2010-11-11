class System::NetworkController < ApplicationController

  def index
    @interfaces = Ifconfig.new.interfaces
  end

  def edit
    begin
      @interface = Ifconfig.new(params[:id]).conf
      if params['interface']
        @interface.attributes = params[:interface]
        if @interface.save
          flash[:notice] = "Interface configuration save successfully"
        end
      end
    rescue
      flash[:error] = $!
    end
  end

end
