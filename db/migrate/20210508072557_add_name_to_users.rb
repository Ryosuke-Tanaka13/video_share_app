# frozen_string_literal: true

class AddNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :integer, default: 0, null: false
    add_reference :users, :organization, default: 1, null: false, foreign_key: true
    add_column :users, :is_valid, :boolean, default: true, null: false
  end
end
