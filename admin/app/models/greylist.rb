class Greylist < ActiveRecord::Base
  establish_connection :sqlgrey_db
  set_table_name :connect
end
