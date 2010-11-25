class RemoveOld < ActiveRecord::Migration
  def self.up
    drop_table :vacations
    rename_column :domains, :domain, :name
  end

  def self.down
    rename_column :domains, :name, :domain
    create_table "vacations", :force => true do |t|
      t.integer "user_id",    :null => false
      t.string  "subject",    :null => false
      t.text    "message"
      t.date    "expire"
      t.date    "created_at"
      t.date    "updated_at"
    end
  end

end
