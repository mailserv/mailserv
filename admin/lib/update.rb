class Update
  require 'timeout'
  attr_accessor :state, :filename, :updates
  attr_reader :is_available, :available_updates

  def initialize
    @os_version   = %x{uname -r}.strip
    @version      = Version.new
    @download_cmd = "/usr/local/bin/wget"
    @state        = "init"
  end

  def updates
    @updates ||= available_updates
  end

  def update_available?
    @updates ? @updates.size > 0 : false
  end

  def download(filename)
    @filename = filename
    @state = "downloading"
    @download_state = spawn do
      %x{#{@download_cmd} -o /tmp/download_update.log -O /var/tmp/#{@filename} #{get_url(filename)}}
    end
  end

  def download_update_progress
    %x{tail -2 /tmp/download_update.log | head -1}.strip =~ /(\d+)K[\s\.]+(\d+)%\s+([\d\.]+)/
    { :downloaded => $1.to_i, :percent => $2.to_i, :speed => $3.to_i }
  end

  def download_complete?
    !@download_state.is_running?
  end

  def extract
    @state = "extracting"
    %x{/usr/bin/install -m 755 /usr/local/share/mailserv/update.sh /tmp}
    @extract_state = spawn do
      %x{/tmp/update.sh /var/tmp/#{@filename}}
    end
  end

  def extract_complete?
    if @extract_state.nil?
      return false
    else
      !@extract_state.is_running?
    end
  end

  def extract_output
    %x{tail -30 "/tmp/update.log"}.strip.gsub("/\n/", "<br />\n")
  end

  def available_updates
    updates = []
    Timeout::timeout(10) do
      SystemUpdate.find(:all, :params => { :product => CONF["product"],
        :osversion => @os_version }).each do |update|
        if update.filename =~ /upgrade/
          updates << update
        elsif update.filename =~ /update.*v([\d\.]+)\.tgz/
          updates << update if @version.to_i < Version.new($1).to_i
        end
      end
    end
    updates
  end

  private

  def get_url(filename)
    updates.each do |update|
      return update.url if update.url =~ /#{filename}/
    end
  end
  
end
