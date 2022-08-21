class AddOrganizationIdToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :organization_id, :integer, default: 1, null: false
  end
end
