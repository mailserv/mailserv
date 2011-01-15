class CreateSystemMigrations < ActiveRecord::Migration
  def self.up
    create_table :system_migrations, :id => false do |t|
      t.string :version
    end
  end

  def self.down
    drop_table :system_migrations
  end

end
