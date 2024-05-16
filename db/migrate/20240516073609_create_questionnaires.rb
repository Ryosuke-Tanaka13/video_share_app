class CreateQuestionnaires < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaires do |t|
      t.string :name
      t.string :email
      t.references :user, null: false, foreign_key: true
      t.text :pre_video_questionnaire
      t.text :post_video_questionnaire

      t.timestamps
    end
  end
end