class CreateQuestionnaires < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaires, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.string :name
      t.string :email
      t.bigint :user_id, null: false
      t.text :pre_video_questionnaire
      t.text :post_video_questionnaire
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
      t.datetime :deleted_at
      t.index :deleted_at
      t.index :user_id
    end
  end
end
