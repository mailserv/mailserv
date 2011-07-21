class Greylist::GreylistedController < ApplicationController

  active_scaffold :greylist do |config|
    config.label = "Greylisted Servers"
    config.columns = [:id, :rcpt, :sender_name, :sender_domain, :src, :first_seen]

    config.action_links.add 'whitelist', :label => 'Whitelist IP', 
      :type => :record, :page => true, :confirm => "Are you sure you want to whitelist this sender IP address?"

    config.list.per_page = 30
    config.actions = [:list, :search, :delete]
    config.columns[:rcpt].label = "Recipient"
    config.columns[:sender_name].label = "Sender Username"
    config.columns[:src].label = "Src IP Address"
  end

  def whitelist
    ip = Greylist.find(params[:id]).src
    whitelist = Whitelist.new(:value => ip)
    if whitelist.save
      Greylist.delete_all(:src => ip)
      flash[:notice] = "Whitelisted #{ip} and delete all corresponding greylist entries"
    else
      flash[:error] = "#{ip} already whitelisted"
    end
    redirect_to :action => 'index'
  end

end
