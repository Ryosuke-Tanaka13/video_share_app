class AddQuestionnaireItemIdToQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_answers, :questionnaire_item_id, :bigint
  end
end
