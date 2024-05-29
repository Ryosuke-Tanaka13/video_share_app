class AddUserIdToQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_answers, :user_id, :integer
    add_index :questionnaire_answers, :user_id
  end
end
