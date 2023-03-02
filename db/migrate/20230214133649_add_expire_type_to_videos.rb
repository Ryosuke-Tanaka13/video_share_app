class AddExpireTypeToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :expire_type, :integer, default: 0, null: false
  end
end
