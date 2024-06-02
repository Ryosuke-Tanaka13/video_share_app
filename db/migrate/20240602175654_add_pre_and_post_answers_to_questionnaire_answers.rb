class AddPreAndPostAnswersToQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_answers, :pre_answers, :text
    add_column :questionnaire_answers, :post_answers, :text
  end
end
