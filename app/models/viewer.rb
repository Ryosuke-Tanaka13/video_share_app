# frozen_string_literal: true

class Viewer < ApplicationRecord
  has_many :organization_viewers, dependent: :destroy
  has_many :organizations, through: :organization_viewers
  has_many :video_statuses, dependent: :destroy
  has_many :videos, through: :video_statuses

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  # 引数のorganization_idと一致するviewerの絞り込み
  scope :current_owner_has, lambda { |current_user|
                              includes(:organization_viewers).where(organization_viewers: { organization_id: current_user.organization_id })
                            }
  scope :viewer_has, lambda { |organization_id|
                       includes(:organization_viewers).where(organization_viewers: { organization_id: organization_id })
                     }

  # 退会者は省く絞り込み
  scope :subscribed, -> { where(is_valid: true) }

  # viewers::video_statuses#indexで呼び出し
  scope :completely_watched_valid_true, lambda { |video_id|
                                          includes(:video_statuses).where(
                                                                          video_statuses: {
                                                                            video_id: video_id, watched_ratio: 100.0, is_valid: true
                                                                          }
                                                                        )
                                        }

  scope :completely_watched, lambda { |video_id|
                               includes(:video_statuses).where(video_statuses: { video_id: video_id, watched_ratio: 100.0 })
                             }

  # videos#showで呼び出し
  def video_status_of_the_set_video(video_id)
    VideoStatus.find_by(viewer_id: self.id, video_id: video_id)
  end

  # ensure_my_organization_videos, ensure_my_organization_set_video, ensure_my_organization内の処理で使用
  def ensure_member(organization_id)
    OrganizationViewer.where(viewer_id: self.id, organization_id: organization_id)
  end
end
