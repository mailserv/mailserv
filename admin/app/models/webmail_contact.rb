class WebmailContact < ActiveRecord::Base
  establish_connection :webmail_db_dev if ENV["RAILS_ENV"] == "development"
  establish_connection :webmail_db     if ENV["RAILS_ENV"] == "production"
  set_table_name :contacts
  belongs_to :user
end
