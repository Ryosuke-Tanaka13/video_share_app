class AddDeletedAtToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :deleted_at, :datetime
  end
end
