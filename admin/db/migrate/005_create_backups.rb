class CreateBackups < ActiveRecord::Migration

  def self.up
    create_table :backups do |t|
      t.column "protocol",              :string
      t.column "encryption_key",        :string
      t.column "hostname",              :string
      t.column "username",              :string
      t.column "password",              :string
      t.column "directory",             :string
      t.column "s3_access_key_id",      :string
      t.column "s3_secret_access_key",  :string
      t.column "s3_bucket",             :string
      t.timestamps
    end
  end

  def self.down
    drop_table :backups
  end

end
