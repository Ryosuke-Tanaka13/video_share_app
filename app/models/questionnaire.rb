class Questionnaire < ApplicationRecord
  belongs_to :user

  serialize :pre_video_questionnaire, JSON
  serialize :post_video_questionnaire, JSON
end
