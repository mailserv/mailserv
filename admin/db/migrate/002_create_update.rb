class CreateUpdate < ActiveRecord::Migration

  def self.up
    create_table :updates do |t|
      t.column "email",      :string, :limit => 128
      t.column "password",   :string, :limit => 64
    end
  end

  def self.down
    drop_table :updates
  end
end
