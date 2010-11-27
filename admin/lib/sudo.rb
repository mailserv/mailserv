require 'tempfile'
class Sudo

  def self.install(sourcefile, destinationfile, options = {})
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      user  = options[:user]  || "root"
      group = options[:group] || "wheel"
      mode  = options[:mode]  || 644
      %x{sudo install -o #{user} -g #{group} -m #{mode} #{sourcefile} #{destinationfile}}
    else
      mode  = options[:mode]  || 644
      %x{install -m #{mode} #{Rails.root}/tmp/root/#{Rails.env}/#{sourcefile} #{Rails.root}/tmp/root/#{Rails.env}/#{destinationfile}}
    end
  end

  def self.tempfile(data)
    datafile = Tempfile.new("_temp")
    datafile.puts data
    datafile.close
    datafile.path
  end

  def self.write(destination, data, options = {})
    f = Tempfile.new("_write")
    f.puts data
    f.close

    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      user  = options[:user]  || "root"
      group = options[:group] || "wheel"
      mode  = options[:mode]  || 644
      %x{sudo install -o #{user} -g #{group} -m #{mode} #{f.path} #{destination}}
    when Rails.env.development?, Rails.env.test?
      mode  = options[:mode]  || 644
      %x{install -m #{mode} #{f.path} #{Rails.root}/tmp/root/#{Rails.env}/#{destination}}
    end
  end

  def self.exec(command, options = {})
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      user = options[:user] || "root"
      %x{sudo -u #{user} #{command}}
    when Rails.env.development?
      %x{#{command}}
    when Rails.env.test?
      "sudo #{command}"
    end
  end

  def self.rake(command, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      user = options[:user] || "root"
      system("sudo -u #{user} /usr/local/bin/rake #{command} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/production.log &")
    when Rails.env.development?
      system("/usr/local/bin/rake #{command} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/development.log &")
    when Rails.env.test?
      "/usr/local/bin/rake #{command} #{args.join(' ')} --trace 2>&1 >> /var/log/rails.log &"
    end
  end

  def self.killall(application)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      %x{sudo pkill -1 -f #{application}}
    end
  end

  def self.read(filename)
    case
    when Rails.env.production? || %x{uname -s}.match(/OpenBSD/)
      %x{sudo cat #{filename} 2>/dev/null}.strip
    else
      %x{cat #{Rails.root}/tmp/root/#{Rails.env}/#{filename}}.strip
    end
  end

  def self.file_exists?(filename)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      File.exists?(filename)
    else
      File.exists?("#{Rails.root}/tmp/root/#{Rails.env}/#{filename}")
    end
  end

  def self.rm(filename)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      %x{sudo rm #{filename} 2>/dev/null}.strip
    else
      %x{rm #{Rails.root}/tmp/root/#{Rails.env}/#{filename}}
    end
  end

  def self.rm_rf(filename)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      %x{sudo rm -rf #{filename} 2>/dev/null}.strip
    else
      %x{rm -rf #{Rails.root}/tmp/root/#{Rails.env}/#{filename}}
    end
  end

  def self.ln_s(source, destination, options = {})
    flags  = "-s"
    flags  = ""  if options[:hard]
    flags += "f" if options[:force]
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      %x{sudo ln #{flags} #{source} #{destination} 2>/dev/null}
    else
      %x{ln #{flags} #{Rails.root}/tmp/root/#{Rails.env}/#{source} #{Rails.root}/tmp/root/#{Rails.env}/#{destination}}
    end
  end

  def self.symlink?(filename)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      File.symlink?(filename)
    else
      File.symlink?("#{Rails.root}/tmp/root/#{Rails.env}/#{filename}")
    end
  end

  def self.readlink(filename)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      File.readlink(filename)
    else
      File.readlink("#{Rails.root}/tmp/root/#{Rails.env}/#{filename}")
    end
  end

  def self.ls(filename)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      %x{sudo ls #{filename}}
    else
      %x{ls #{Rails.root}/tmp/root/#{Rails.env}/#{filename}}
    end
  end

  def self.directory?(directory)
    case
    when Rails.env.production? || `uname -s`.strip == "OpenBSD"
      File.directory?(directory)
    else
      File.directory?("#{Rails.root}/tmp/root/#{Rails.env}/#{directory}")
    end
  end

  def self.initialize_test
    if %x{which rsync; echo $?}.to_i.zero?
      %x{rsync -a --delete #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/root/test/}
    else
      %x{
        rm -rf #{Rails.root}/tmp/root/test
        cp -rp #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/root/test/
      }
    end
  end

  def self.init_dev_from_test
    if %x{which rsync; echo $?}.to_i.zero?
      %x{rsync -a --delete #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/root/development/}
    else
      %x{
        rm -rf #{Rails.root}/tmp/root/test
        cp -rp #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/root/development/
      }
    end
  end

end
