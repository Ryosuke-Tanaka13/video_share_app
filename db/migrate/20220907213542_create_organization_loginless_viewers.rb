class CreateOrganizationLoginlessViewers < ActiveRecord::Migration[6.1]
  def change
    create_table :organization_loginless_viewers do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :loginless_viewer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
