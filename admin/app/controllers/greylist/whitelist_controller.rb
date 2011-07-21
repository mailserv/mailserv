class Greylist::WhitelistController < ApplicationController

  active_scaffold :whitelist do |config|
    config.label = "Whitelisted Servers"
    config.columns = [:id, :value, :description, :updated_at]

    config.list.per_page = 30
    
    config.create.columns.exclude :id
    config.update.columns.exclude :id

    config.columns[:value].description = "example: 10.1.2.3, mail.example.com, *.example.com, /some_regexp/"
  end

end
