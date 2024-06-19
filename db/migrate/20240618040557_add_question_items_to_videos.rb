class AddQuestionItemsToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :pre_question_items, :json
    add_column :videos, :post_question_items, :json
  end
end
