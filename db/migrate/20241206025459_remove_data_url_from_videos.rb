class RemoveDataUrlFromVideos < ActiveRecord::Migration[6.1]
  def change
    remove_column :videos, :data_url, :string
  end
end
