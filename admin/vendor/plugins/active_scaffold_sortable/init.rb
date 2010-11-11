require "actions/sortable.rb"
require "config/sortable.rb"
require "extensions/resources.rb"


# install files
['/public/images'].each{|dir|
  source = File.join(directory,dir)
  dest = File.join(RAILS_ROOT, dir)
  FileUtils.mkdir_p(dest)
  FileUtils.cp_r(Dir.glob(source+'/*.*'), dest)
} unless File.exists?(RAILS_ROOT + '/public/images/arrow_move.png')
