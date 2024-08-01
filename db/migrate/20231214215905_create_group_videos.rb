class CreateGroupVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :group_videos do |t|
      t.references :group, null: false, foreign_key: true
      t.references :video, null: false, foreign_key: true

      t.timestamps
    end
  end
end
