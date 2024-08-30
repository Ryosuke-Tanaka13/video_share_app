class CreateQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaire_answers, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.bigint :viewer_id
      t.bigint :video_id
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
      t.string :viewer_name
      t.string :viewer_email
      t.integer :user_id
      t.json :pre_answers
      t.json :post_answers
      t.bigint :questionnaire_item_id
      t.index :user_id
      t.index :video_id
      t.index :viewer_id
    end
  end
end
