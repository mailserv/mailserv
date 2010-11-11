class System::AdministratorsController < ApplicationController

  active_scaffold :admins do |config|
    config.columns = [:username, :email, :pass, :pass_confirmation]
    config.list.columns.exclude :pass, :pass_confirmation
    config.actions.swap :search, :live_search
    config.actions.exclude :show
    config.list.per_page = 20
    columns[:pass].form_ui = :password
    columns[:pass_confirmation].form_ui = :password

    config.create.columns.exclude :id
    config.update.columns.exclude :id
  end

end
