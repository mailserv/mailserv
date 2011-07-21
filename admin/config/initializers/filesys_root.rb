case RAILS_ENV
when 'development'
  if `uname -r`.strip == "Darwin"
    FILESYS_ROOT = RAILS_ROOT + "/dev/root/"
  else
    FILESYS_ROOT = "/"
  end

when 'production'
  FILESYS_ROOT = "/"

when 'test'
  FILESYS_ROOT = RAILS_ROOT + "/test/root/"

end