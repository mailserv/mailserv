class Spamcontroldb < ActiveRecord::Base
  establish_connection :spamcontrol_db_dev if ENV["RAILS_ENV"] == "development"
  establish_connection :spamcontrol_db     if ENV["RAILS_ENV"] == "production"  
  set_table_name :userpref
end