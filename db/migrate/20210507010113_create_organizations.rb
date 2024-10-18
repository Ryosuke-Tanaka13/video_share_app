class CreateOrganizations < ActiveRecord::Migration[6.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :email
      t.boolean :is_valid, default: true, null: false

      t.timestamps
    end
  end
end
