class ChangeVideoIdNullInQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    change_column_null :questionnaire_answers, :video_id, true
  end
end
