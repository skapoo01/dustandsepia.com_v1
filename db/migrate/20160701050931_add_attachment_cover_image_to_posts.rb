class AddAttachmentCoverImageToPosts < ActiveRecord::Migration
  def self.up
    change_table :posts do |t|
      t.attachment :cover_image
    end
  end

  def self.down
    remove_attachment :posts, :cover_image
  end
end
