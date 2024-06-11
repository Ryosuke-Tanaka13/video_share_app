class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire_item
  belongs_to :questionnaire
  belongs_to :user, optional: true

  validates :pre_answers, presence: true, if: -> { questionnaire&.pre_video_questionnaire.present? && pre_answers.present? }
  validates :post_answers, presence: true, if: -> { questionnaire&.post_video_questionnaire.present? && post_answers.present? }
end
