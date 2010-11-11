require File.dirname(__FILE__) + '/../test_helper'

class BackupTest < ActiveSupport::TestCase

  def test_backup_validations
    backup = Backup.new(:protocol => 'sftp', :hostname => "test.example.com", 
      :username => 'root', :password => "password")
    assert backup.valid?
  end

  def test_backup_without_username
    backup = Backup.new(:protocol => 'sftp', :hostname => "test.example.com")
    assert !backup.valid? # should fail
  end

end
