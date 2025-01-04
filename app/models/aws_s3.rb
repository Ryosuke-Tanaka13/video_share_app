class AwsS3 < ApplicationRecord
  has_one_attached :file

  # S3にアップロードするファイルの条件を制限している
    # active_storage_validaterで機能する
  validates: file,
             content_type: ['video/mp4', 'video/mov'],
             size: { less_than: 500.megabytes}
end
