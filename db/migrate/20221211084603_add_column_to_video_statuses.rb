class AddColumnToVideoStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :video_statuses, :latest_end_point, :float
    add_column :video_statuses, :total_time, :float
    add_column :video_statuses, :watched_ratio, :float
    add_column :video_statuses, :watched_at, :datetime
    add_column :video_statuses, :video_id, :integer, null: false
    add_column :video_statuses, :viewer_id, :integer, null: false
    add_column :video_statuses, :is_valid, :boolean, default: true
    
    add_index :video_statuses, [:viewer_id, :video_id], unique: true
  end
end
