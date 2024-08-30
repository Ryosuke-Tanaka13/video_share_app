class AddMissingColumnsToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :pre_video_questionnaire, :text
    add_column :videos, :post_video_questionnaire, :text
    add_column :videos, :pre_video_questionnaire_id, :integer
    add_column :videos, :post_video_questionnaire_id, :integer
    add_column :videos, :pre_question_items, :json
    add_column :videos, :post_question_items, :json
    add_index :videos, :deleted_at, name: "index_videos_on_deleted_at"
  end
end
