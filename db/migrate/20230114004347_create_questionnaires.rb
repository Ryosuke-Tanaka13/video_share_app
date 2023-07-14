class CreateQuestionnaires < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaires do |t|
      t.string :organization_id
      t.string :title
      t.boolean :use_at

      t.timestamps
    end
  end
end
