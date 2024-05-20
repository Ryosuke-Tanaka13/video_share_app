class AddQuestionnairesToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :pre_video_questionnaire, :text
    add_column :videos, :post_video_questionnaire, :text
  end
end
