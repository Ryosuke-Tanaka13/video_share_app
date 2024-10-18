class CreateVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :videos do |t|
      t.string :title
      t.integer :audience_rate
      t.datetime :open_period
      t.boolean :range, default:false
      t.boolean :comment_public, default:false
      t.boolean :login_set, default:false
      t.boolean :popup_before_video, default:false
      t.boolean :popup_after_video, default:false
      t.string :data_url, null: false
      t.boolean :is_valid, default:true, null:false

      t.references :organization, null: false, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
