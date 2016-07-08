class SetUserAdminAndActiveDefaults < ActiveRecord::Migration
  def up
  	change_column :users, :admin, :boolean, :default => false
  	change_column :users, :active, :boolean, :default => true

  end

  def down
  	change_column :users, :admin, :boolean, :default => nil
  	change_column :users, :active, :boolean, :default => nil
  end

end
