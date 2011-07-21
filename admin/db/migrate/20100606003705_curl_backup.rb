class CurlBackup < ActiveRecord::Migration
  def self.up
    add_column :backups, :location, :string
    remove_column :backups, :username
    remove_column :backups, :password
    remove_column :backups, :directory
    remove_column :backups, :protocol
    remove_column :backups, :hostname
    remove_column :backups, :s3_bucket
    remove_column :backups, :s3_secret_access_key
    remove_column :backups, :s3_access_key_id
  end

  def self.down
    remove_column :backups, :location
    add_column :backups, :username, :string
    add_column :backups, :password, :string
    add_column :backups, :directory, :string
    add_column :backups, :protocol, :string
    add_column :backups, :hostname, :string
    add_column :backups, :s3_bucket, :string
    add_column :backups, :s3_secret_access_key, :string
    add_column :backups, :s3_access_key_id, :string
  end
end

