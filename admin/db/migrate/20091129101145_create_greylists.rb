class CreateGreylists < ActiveRecord::Migration

  def self.up
    create_table :greylists do |t|
      t.string      :action, :clause, :value, :rcpt, :description
      t.boolean     :nolog
      t.integer     :position
      t.timestamps
    end
    Greylist.reset_column_information
    Greylist.create!(
      :position     => 1,
      :action       => "whitelist",
      :clause       => "addr",
      :value        => "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16",
      :description  => "My Networks"
    )
  end

  def self.down
    drop_table :greylists
  end

end
