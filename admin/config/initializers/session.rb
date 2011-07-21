# Be sure to restart your server when you modify this file.
secret_file = File.join(RAILS_ROOT, "tmp", "session.key")
unless File.size?(secret_file)
  %x{/usr/local/bin/rake -s -f #{Rails.root}/Rakefile secret > #{secret_file}}
end
secret = File.read(secret_file)

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_admin_session',
  :secret      => secret
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store

# Expire sessions after a week
#ActionController::Base.session_options[:expire_after] = 1.week

