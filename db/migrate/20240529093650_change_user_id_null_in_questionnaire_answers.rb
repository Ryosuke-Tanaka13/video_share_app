class ChangeUserIdNullInQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    change_column_null :questionnaire_answers, :user_id, true
  end
end
