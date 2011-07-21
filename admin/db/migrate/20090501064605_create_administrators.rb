class CreateAdministrators < ActiveRecord::Migration
  def self.up
    create_table :administrators do |t|
      t.integer :domain_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :administrators
  end
end
