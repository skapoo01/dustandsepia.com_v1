class AddColumnsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :publish, :boolean, :default => true
    add_column :posts, :commenting, :boolean, :default => true
    add_column :posts, :views, :integer
    add_column :posts, :rating, :float, :default => 0
  end
end
