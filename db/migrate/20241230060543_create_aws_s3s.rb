class CreateAwsS3s < ActiveRecord::Migration[6.1]
  def change
    create_table :aws_s3s do |t|
      t.string :title
      t.string :file_url
      t.string :thumbnail_url
      t.string :status

      t.timestamps
    end
  end
end
