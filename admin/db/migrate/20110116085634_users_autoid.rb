class UsersAutoid < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = 2000;")
  end

  def self.down
  end
end
