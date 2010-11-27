class GreylistController < ApplicationController

  active_scaffold :greylist do |config|
    config.label = "Greylisted Servers"
    config.columns = [:id, :rcpt, :sender_name, :sender_domain, :src, :first_seen]

    config.list.per_page = 30
    config.actions = [:list, :search, :delete]
    config.columns[:rcpt].label = "Recipient"
    config.columns[:sender_name].label = "Sender Username"
    config.columns[:src].label = "Src IP Address"
  end

# alter table connect add id int primary key auto_increment first;
  
end
