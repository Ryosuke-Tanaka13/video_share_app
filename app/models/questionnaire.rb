class Questionnaire < ApplicationRecord
  belongs_to :user
  acts_as_paranoid
  has_many :questionnaire_answers
  
  # Assuming pre_video_questionnaire and post_video_questionnaire are stored as JSON or YAML
  serialize :pre_video_questionnaire, JSON
  serialize :post_video_questionnaire, JSON
end
