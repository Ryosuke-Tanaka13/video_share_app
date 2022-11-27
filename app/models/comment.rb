class Comment < ApplicationRecord
  belongs_to :organization
  belongs_to :video
  belongs_to :system_admin, optional: true
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true

  has_many :replies, dependent: :destroy

  # バリデーション
  validates :comment, presence: true
end
