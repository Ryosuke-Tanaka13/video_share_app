class AddPlanToOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :plan, :integer
    add_column :organizations, :payment_success, :boolean, default: false
    add_column :organizations, :customer_id, :string
    add_column :organizations, :subscription_id, :string
  end
end
