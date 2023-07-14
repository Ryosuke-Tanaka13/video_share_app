class CreateQuestionnaireItems < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaire_items do |t|
      t.integer :questionnaire_id
      t.string :name
      t.string :type
      t.integer :order_number
      t.timestamps
    end
  end
end
