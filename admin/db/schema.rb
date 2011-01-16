# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101216072412) do

  create_table "administrators", :force => true do |t|
    t.integer  "domain_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", :force => true do |t|
    t.string   "username",   :limit => 32,  :default => "", :null => false
    t.string   "password",   :limit => 32,  :default => "", :null => false
    t.string   "email",      :limit => 128
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["username"], :name => "admins_uniq", :unique => true

  create_table "backups", :force => true do |t|
    t.string   "encryption_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
  end

  create_table "domains", :force => true do |t|
    t.string   "name",       :limit => 128
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quota"
    t.integer  "quotamax"
  end

  add_index "domains", ["name"], :name => "domain_uniq", :unique => true

  create_table "forwardings", :force => true do |t|
    t.integer  "domain_id",                  :default => 0,  :null => false
    t.string   "source",      :limit => 128, :default => "", :null => false
    t.text     "destination",                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "greylists", :force => true do |t|
    t.string   "action"
    t.string   "clause"
    t.string   "value"
    t.string   "rcpt"
    t.string   "description"
    t.boolean  "nolog"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hostconfigs", :force => true do |t|
    t.text     "interfaces"
    t.text     "routes"
    t.text     "nameservers"
    t.text     "ntpservers"
    t.text     "certificate"
    t.text     "certificate_key"
    t.text     "certificate_ca"
    t.string   "hostname"
    t.string   "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", :force => true do |t|
    t.string "hostname", :limit => 256
    t.string "code",     :limit => 40
  end

  create_table "routings", :force => true do |t|
    t.string "destination", :limit => 128
    t.string "transport",   :limit => 128
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "system_migrations", :id => false, :force => true do |t|
    t.string "version"
  end

  create_table "userpref", :primary_key => "prefid", :force => true do |t|
    t.string "username",   :limit => 100, :default => "", :null => false
    t.string "preference", :limit => 50,  :default => "", :null => false
    t.string "value",      :limit => 100, :default => "", :null => false
  end

  add_index "userpref", ["username"], :name => "username"

  create_table "users", :force => true, :options => "auto_increment = 2000" do |t|
    t.integer  "domain_id"
    t.string   "email",      :limit => 128, :default => "", :null => false
    t.string   "name",       :limit => 128
    t.string   "fullname",   :limit => 128
    t.string   "password",   :limit => 32,  :default => "", :null => false
    t.string   "home",                      :default => "", :null => false
    t.integer  "priority",                  :default => 7,  :null => false
    t.integer  "policy_id",                 :default => 1,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quota"
  end

  create_table "whitelists", :force => true do |t|
    t.string   "value"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
