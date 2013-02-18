class System::LogsController < ApplicationController
  LOGSIZE = 20000
  def index
    begin
      @logs = [
        {:path => '/var/log/maillog_webmin', :logdata => '', :accessible => false},
        {:path => '/var/log/clam-update.log', :logdata => '', :accessible => false},
        {:path => '/var/log/messages_webmin.log', :logdata => '', :accessible => false},
        {:path => '/var/log/imap_webmin', :logdata => '', :accessiable => false},
        {:path => '/var/log/httpd.err', :logdata => '', :accessible => false},
        {:path => '/var/log/httpd.log', :logdata => '', :accessible => false},
        {:path => '/var/mailserv/admin/log/production.log', :logdata => '', :accessible => false}
      ]
      @logs.each do |log|
        if File.exist?(log[:path]) && File.readable?(log[:path])
          File.open(log[:path]) do |file|
            if File.size(log[:path]) > LOGSIZE
              file.seek(-LOGSIZE, IO::SEEK_END)
            end
            log[:logdata] = file.read
            log[:accessible] = true
          end
        end
      end
    rescue
      flash[:error] = $!
    end
  end
end
