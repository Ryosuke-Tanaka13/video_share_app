class Reply < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :comment

  # バリデーション
  validates :reply, presence: true

end
