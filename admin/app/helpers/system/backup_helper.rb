module System::BackupHelper

  def display_filename(filename)
    filename =~ /backup-(.*)\.tgz/
    $1
  end

  def display_filename_ext(filename)
    filename =~ /.*\.(.*)\.tgz/
    $1
  end

  def get_filename_from_id(id)
    if id =~ /\d+/
      return "backup-" + %x{hostname}.strip + ".incr." + params[:id] + ".tgz"
    else
      return "backup-" + %x{hostname}.strip + "." + params[:id] + ".tgz"
    end
  end

end
