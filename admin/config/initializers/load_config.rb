CONF = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

require 'spawn'
include Spawn
require 'fileutils'
include FileUtils
#require 'net/ssh'
#require 'net/sftp'
require 'fastercsv'

# Ensure that the database is tweaked properly 
if %x{sudo /usr/local/bin/mysqldump mail users -d}.to_s.match(/AUTO_INCREMENT=(\d+)/)[1].to_i < 2000 rescue false
  %x{sudo /usr/local/bin/mysql mail -e "ALTER TABLE users AUTO_INCREMENT = 2000;"}
end if Rails.env.production?
