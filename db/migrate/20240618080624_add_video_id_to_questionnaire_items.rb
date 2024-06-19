class AddVideoIdToQuestionnaireItems < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_items, :video_id, :integer
    add_index :questionnaire_items, :video_id
  end
end
