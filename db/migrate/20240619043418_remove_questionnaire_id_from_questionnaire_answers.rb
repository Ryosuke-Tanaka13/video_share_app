class RemoveQuestionnaireIdFromQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    remove_column :questionnaire_answers, :questionnaire_id, :integer
  end
end
