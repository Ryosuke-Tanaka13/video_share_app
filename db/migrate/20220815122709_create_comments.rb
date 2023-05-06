class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :comment, null: false
      t.references :organization, null: false, foreign_key: true
      t.references :video, null: false, foreign_key: true
      t.references :system_admin, foreign_key: true
      t.references :user, foreign_key: true
      t.references :viewer, foreign_key: true

      t.timestamps
    end
  end
end
