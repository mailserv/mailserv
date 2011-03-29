CONF = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

require 'spawn'
include Spawn
require 'fileutils'
include FileUtils
#require 'net/ssh'
#require 'net/sftp'
require 'fastercsv'
