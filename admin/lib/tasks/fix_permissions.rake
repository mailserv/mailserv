$stdout.sync = true
namespace :mailserv do

  desc "Fix the filsystem permissions for all users"
  task :fix_permissions => :environment do
    %x{/usr/local/bin/sudo chmod 755 /var/mailserv/mail/*}
    User.all.each do |user|
      mail_dir = "/var/mailserv/mail/#{user.domain.name}/#{user.name}"
      %x{
        /usr/local/bin/sudo chown -R #{user.id}:#{user.id} "#{mail_dir}"
        find "#{mail_dir}" -type d -exec /usr/local/bin/sudo chmod 750 {} \\\;
      }
      putc "."
    end
    puts "\nfixed permissions\n"
  end
  
end
