class QuestionnaireItem < ApplicationRecord
  belongs_to :video
  has_many :questionnaire_answers, dependent: :destroy
  validates :pre_question_text, presence: true, if: -> { pre_question_text.present? }
  validates :post_question_text, presence: true, if: -> { post_question_text.present? }
end
