class AddIdDigestToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :id_digest, :string unless column_exists?(:videos, :id_digest)
  end
end