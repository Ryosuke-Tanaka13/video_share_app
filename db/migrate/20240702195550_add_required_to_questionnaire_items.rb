class AddRequiredToQuestionnaireItems < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_items, :required, :boolean
  end
end
