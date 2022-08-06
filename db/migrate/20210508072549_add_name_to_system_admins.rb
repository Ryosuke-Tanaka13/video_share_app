# frozen_string_literal: true

class AddNameToSystem_admins < ActiveRecord::Migration[6.1]
  def change
    add_column :system_admins, :name, :string
  end
end
