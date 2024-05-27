class CreateQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :questionnaire_answers do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.references :viewer, null: false, foreign_key: true
      t.references :video, null: false, foreign_key: true
      t.text :answer

      t.timestamps
    end
  end
end

