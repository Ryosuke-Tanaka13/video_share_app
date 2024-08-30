class CreateQuestionnaireItems < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaire_items, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.bigint :questionnaire_id
      t.string :pre_question_text
      t.string :pre_question_type
      t.json :pre_options
      t.string :post_question_text
      t.string :post_question_type
      t.json :post_options
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
      t.bigint :video_id
      t.boolean :required
      t.index :questionnaire_id
      t.index :video_id
    end
  end
end
