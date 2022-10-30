class CreateFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :folders do |t|
      t.string :name
      t.bigint :organization_id
      t.integer :video_folder_id

      t.timestamps
    end
  end
end
