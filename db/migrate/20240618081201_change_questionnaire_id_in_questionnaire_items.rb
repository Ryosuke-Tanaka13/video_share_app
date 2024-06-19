class ChangeQuestionnaireIdInQuestionnaireItems < ActiveRecord::Migration[6.1]
  def change
    change_column_null :questionnaire_items, :questionnaire_id, true
  end
end