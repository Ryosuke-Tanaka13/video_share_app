class AddPreAndPostQuestionsToQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_answers, :pre_questions, :text
    add_column :questionnaire_answers, :post_questions, :text
  end
end
