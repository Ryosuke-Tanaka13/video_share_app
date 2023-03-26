class AddIdDigestToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :id_digest, :string
  end
end
