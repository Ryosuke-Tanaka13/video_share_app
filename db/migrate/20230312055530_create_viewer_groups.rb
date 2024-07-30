class CreateViewerGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :viewer_groups do |t|
      t.references :viewer, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
