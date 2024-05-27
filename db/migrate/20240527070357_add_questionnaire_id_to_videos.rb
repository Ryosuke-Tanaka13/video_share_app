class AddQuestionnaireIdToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :pre_video_questionnaire_id, :integer
    add_column :videos, :post_video_questionnaire_id, :integer
  end
end
