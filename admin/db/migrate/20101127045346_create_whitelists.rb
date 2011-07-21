class CreateWhitelists < ActiveRecord::Migration

  def self.up
    create_table :whitelists do |t|
      t.string :value
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :whitelists
  end

end
