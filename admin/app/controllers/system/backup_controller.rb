class System::BackupController < ApplicationController

  def index
    begin
      @backup = Backup.find(:first) || Backup.new
      if request.post?
        @backup.attributes = params[:backup]
        if @backup.save
          if @backup.location.present?
            flash[:notice] = "Test connection successfull and backup location saved"
          else
            flash[:notice] = "Backup location removed"
          end
          redirect_to :action => 'index'
        end
      else
        @backup.encryption_key_confirmation = @backup.encryption_key if @backup.encryption_key.present?
      end
    rescue
      flash[:error] = $!
    end
  end

  def restore
    @backup = Backup.first || Backup.new
    @restore = @backup.list
    @content = @backup.list_content
    if request.get?
      if @backup.location.blank?
        flash[:error] = "Please configure the backup location before attempting to restore"
        redirect_to :action => 'index'
      elsif @restore.blank?
        flash[:error] = "Can't find any backup files. Please allow the backup to run before attempting to restore"
        redirect_to :action => 'index'
      elsif Backup.restore_is_running?
        flash[:notice] = "Restoration in progress, please wait."
      end
    elsif request.post?
      if params[:restore][:file].present? && !Backup.restore_is_running?
        Sudo.rake "mailserver:restore", :filename => params[:restore][:file], :restore_path => params[:restore][:user]
        flash[:notice] = "Started restoring files from #{params[:restore][:file]}"
        redirect_to :action => 'restore'
      else
        flash[:error] = "Please select a file to restore from"
        redirect_to :action => 'restore'
      end
    end
  end

  def restore_progress
    if Backup.restore_is_running?
      render :partial => "restore_progress"
    else
      flash[:notice] = "Restore complete"
      render :update do |page| page.redirect_to :action => 'restore' end
    end
  end

  def start_backup
    Backup.start_full
    flash[:notice] = "Backup Started"
    redirect_to :action => 'index'
  end

  def abort_backup
    Backup.abort_backup
    flash[:notice] = "Backup Aborted"
    redirect_to :action => 'index'
  end

end
