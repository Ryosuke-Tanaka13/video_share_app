class CreateFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :folders do |t|
      t.string :name
      t.references :organization, null: false, foreign_key: true
      t.integer :video_folder_id

      t.timestamps
    end
  end
end
