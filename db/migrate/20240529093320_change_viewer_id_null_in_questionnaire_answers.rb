class ChangeViewerIdNullInQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    change_column_null :questionnaire_answers, :viewer_id, true
  end
end