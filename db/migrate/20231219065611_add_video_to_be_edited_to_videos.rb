class AddVideoToBeEditedToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :video_to_be_edited, :blob
  end
end
