class CreateLoginlessViewers < ActiveRecord::Migration[6.1]
  def change
    create_table :loginless_viewers do |t|
      t.string :name
      t.string :email
      t.boolean :is_valid, default: true, null: false

      t.timestamps
    end
  end
end
