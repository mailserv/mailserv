class ForwardingsController < ApplicationController

  active_scaffold :forwarding do |config|
    config.columns = [:id, :source, :destination]
    config.actions.swap :search, :live_search
    config.actions.exclude :show
    config.list.per_page = 20

    columns[:source].label = "Arrive to"
    columns[:destination].label = "Deliver to"
    columns[:destination].form_ui = :textarea
    config.create.columns.exclude :id
    config.update.columns.exclude :id
    config.update.label = "Update"
  end

end
