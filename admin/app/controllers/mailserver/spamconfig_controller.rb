class Mailserver::SpamconfigController < ApplicationController

  def index
    @mynetworks  = PostfixMynetworks.new
    @spamcontrol = Spamcontrol.new
    if request.post?
      @mynetworks.networks = params[:spamcontrol][:trusted_networks].split(/[,\s]+/)
      @spamcontrol.required_score = params[:spamcontrol][:required_score]
      @spamcontrol.rewrite_header = params[:spamcontrol][:rewrite_header]
      @spamcontrol.trusted_networks = params[:spamcontrol][:trusted_networks]
      @spamcontrol.kill_level = params[:spamcontrol][:kill_level]
      if @mynetworks.valid? && @spamcontrol.valid? && @mynetworks.save && @spamcontrol.save
        flash[:notice] = "Spam Configuration Saved Successfully"
        redirect_to :action => 'index'
      else
        flash[:error] = ""
        flash[:error] += @mynetworks.error_messages.join("<br />") unless @mynetworks.valid?
        flash[:error] += @spamcontrol.errors.full_messages.join("<br />") unless @spamcontrol.valid?
      end
    end
  end

end
