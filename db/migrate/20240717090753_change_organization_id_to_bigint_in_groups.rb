class ChangeOrganizationIdToBigintInGroups < ActiveRecord::Migration[6.0]
  def up
    change_column :groups, :organization_id, :bigint
  end

  def down
    change_column :groups, :organization_id, :integer
  end
end
