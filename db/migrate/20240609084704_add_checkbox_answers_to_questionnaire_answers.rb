class AddCheckboxAnswersToQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_answers, :checkbox_pre_answers, :json
    add_column :questionnaire_answers, :checkbox_post_answers, :json
  end
end
