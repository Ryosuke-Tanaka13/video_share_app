class RemoveCommentPublicFromVideos < ActiveRecord::Migration[6.1]
  def change
    remove_column :videos, :comment_public, :boolean
  end
end