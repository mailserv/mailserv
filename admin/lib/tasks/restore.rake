$stdout.sync = true
require 'tempfile'
namespace :mailserver do
  
  desc "Restore the Mailserver from a backup"
  task :restore => [:environment] do
    begin
      file = ENV['FILENAME']
      restore_path = ENV['RESTORE_PATH']
      unless backup = Backup.first
        STDERR.puts "Backup not configured"
        exit 1
      end
      if file.blank?
        STDERR.puts "Need to add a filename in the FILENAME environment variable"
        exit 2
      end
      encryption_key = backup.encryption_key
      restore_path = "var/mailserver/mail/" + restore_path unless restore_path.blank?

      if encryption_key.present?
        Rails.logger.debug "/usr/local/bin/curl -k #{backup.location}/#{file} | openssl aes-256-cbc -salt -k \"#{encryption_key}\" -d | /usr/local/bin/gtar zxvfp - -C / #{restore_path}"
        Sudo.exec("/usr/local/bin/curl -k #{backup.location}/#{file} | openssl aes-256-cbc -salt -k \"#{encryption_key}\" -d | /usr/local/bin/gtar zxvfp - -C / #{restore_path}")
      else
        Rails.logger.debug "/usr/local/bin/curl -k #{backup.location}/#{file} | /usr/local/bin/gtar zxvfp - -C / #{restore_path}"
        Sudo.exec("/usr/local/bin/curl -k #{backup.location}/#{file} | /usr/local/bin/gtar zxvfp - -C / #{restore_path}")
      end

      if restore_path.blank?
        if file =~ /full/
          db_backup_file = %x{ls -t /var/mailserver/backup | head -1}.strip
        else
          file =~ /incr.(\d+).tgz/
          db_backup_file = %x{ls /var/mailserver/backup | grep #{$1} | head -1}.strip  
        end
        Sudo.exec "/usr/bin/gzip -cd /var/mailserver/backup/#{db_backup_file} | /usr/local/bin/mysql"
        Sudo.rake "db:migrate"
      end
    rescue
      puts "Error: #{$!}\n"
    end
  end

end
