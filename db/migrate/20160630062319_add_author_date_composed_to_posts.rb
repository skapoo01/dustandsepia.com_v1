class AddAuthorDateComposedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :author, :string
    add_column :posts, :composed_on, :date
    add_column :posts, :summary, :string
  end
end
