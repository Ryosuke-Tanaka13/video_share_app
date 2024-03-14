class RemoveCommentPublicFromVideos < ActiveRecord::Migration[6.1]
  def change
    remove_column :videos, :comment_public, :boolean if column_exists? :videos, :comment_public
  end
end