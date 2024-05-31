class RemoveAnswerFromQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    remove_column :questionnaire_answers, :answer, :text
  end
end