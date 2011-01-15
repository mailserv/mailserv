$stdout.sync = true
namespace :mailserv do

  desc "Displays the Installed mailserver version"
  task :version do
    STDOUT.puts "Mailserv #{File.read("/usr/local/share/mailserver/version")}"
  end
  
end
