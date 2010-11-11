class AddQuotaToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :quota, :integer
    add_column :domains, :quota, :integer
    add_column :domains, :quotamax, :integer
  end

  def self.down
    remove_column :users, :quota
    remove_column :domains, :quota
    remove_column :domains, :quotamax
  end
end
