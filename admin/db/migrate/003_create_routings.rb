class CreateRoutings < ActiveRecord::Migration

  def self.up
    create_table :routings do |t|
      t.column "destination", :string, :limit => 128
      t.column "transport",   :string, :limit => 128
    end
    create_table :licenses do |t|
      t.column "hostname",  :string, :limit => 256
      t.column "code",      :string, :limit => 40
    end
    drop_table :updates
  end

  def self.down
    drop_table :routings
    drop_table :licenses
    create_table :updates do |t|
      t.column "email",      :string, :limit => 128
      t.column "password",   :string, :limit => 64
    end
  end

end
