class CreateOrganizationViewers < ActiveRecord::Migration[6.1]
  def change
    create_table :organization_viewers do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :viewer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
