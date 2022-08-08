# frozen_string_literal: true

class AddNameToViewers < ActiveRecord::Migration[6.1]
  def change
    add_column :viewers, :name,   :string
  end
end
