$stdout.sync = true
require 'tempfile'
namespace :mailserver do
  namespace :backup do

    desc "Make a full backup of the Mailserver"
    task :full => [:environment, :init, :mysql] do
      begin
        filename  = "backup-#{`hostname`.strip}.full.tgz"
        tar_command = "#{@gtar} /var/mailserver"

        STDERR.puts header(filename)

        backup_curl(tar_command, filename)

        STDERR.puts footer
        append_log
      rescue
        puts "Error: #{$!}\n"
      end
    end

    desc "Make an incremental backup from the first of every month"
    task :incremental => [:environment, :init, :mysql] do
      begin
        filename  = "backup-#{`hostname`.strip}.incr.#{`date +%d`.strip}.tgz"
        tar_command = "#{@gtar} --newer-mtime=#{`date +%Y-%m-`.strip}01 /var/mailserver"

        STDERR.puts header(filename)

        backup_curl(tar_command, filename)

        STDERR.puts footer
        append_log
      rescue
        puts "Error: #{$!}\n"
      end
    end

    desc "Backup the MySQL database"
    task :mysql do
      %x{/usr/local/bin/mysqldump --all-databases --force 2>/dev/null |\
         gzip -9 > /var/mailserver/backup/db_`date +%Y-%m-%d`.sql.gz}
      # Remove old MySQL backups
      %x{find /var/mailserver/backup -ctime +7 | xargs rm -f}
    end

    private

    task :init do
      @backup = Backup.first || (puts "Backup not configured\n"; exit 1)
      @gtar = "/usr/local/bin/gtar zcvfp -"
      @tf = Tempfile.new("logtemp")
      $stderr.reopen(@tf.path, "w")
      $stderr.sync = true
    end

    def header(filename)
      out  = "\n"
      out += "------------------------------------------------\n"
      out += "Backup beginning at " + %x{date}
      out += "------------------------------------------------\n"
      out += "File: #{filename}\n"
      out += "\n"
      out
    end

    def footer
      out  = "\n"
      out += "------------------------------------------------\n"
      out += "Backup finished at " + %x{date}
      out += "------------------------------------------------\n"
      out += "\n"
      out
    end

    def append_log
      File.open("/var/log/backup.log", "a") do |file|
        @tf.read.each_line do |line|
          next if line =~ /(^\/usr\/local\/bin\/gtar|\/$)/
          puts line
          file.puts line
        end
      end
    end

    def backup_curl(tar_command, filename)
      unless @backup.encryption_key.blank?
        tar_command += " | openssl aes-256-cbc -salt -k " + @backup.encryption_key
      end
      %x{#{tar_command} | /usr/local/bin/curl -ksST - #{@backup.location}/#{filename}}
    end

  end
end
