class CreateHostconfigs < ActiveRecord::Migration
  def self.up
    create_table :hostconfigs do |t|
      t.text        :interfaces, :routes, :nameservers, :ntpservers, :certificate, :certificate_key, :certificate_ca
      t.string      :hostname, :timezone
      t.timestamps
    end
  end

  def self.down
    drop_table :hostconfigs
  end
end
