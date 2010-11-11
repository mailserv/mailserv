$stdout.sync = true
namespace :mailserver do

  desc "Displays the Installed mailserver version"
  task :version do
    STDOUT.puts "Mailserver #{File.read("/usr/local/share/mailserver/version")}"
  end
  
end
