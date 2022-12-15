class CreateVideoStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :video_statuses do |t|

      t.timestamps
    end
  end
end
