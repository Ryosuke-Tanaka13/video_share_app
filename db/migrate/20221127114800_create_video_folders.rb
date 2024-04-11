class CreateVideoFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :video_folders do |t|
      t.references :video, null: false, foreign_key: true
      t.references :folder, null: false, foreign_key: true

      t.timestamps
    end
  end
end
