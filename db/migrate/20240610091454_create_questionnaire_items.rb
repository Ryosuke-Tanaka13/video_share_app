class CreateQuestionnaireItems < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaire_items do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.string :pre_question_text
      t.string :pre_question_type
      t.json :pre_options
      t.string :post_question_text
      t.string :post_question_type
      t.json :post_options
      t.timestamps
    end
  end
end