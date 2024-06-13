class QuestionnaireItem < ApplicationRecord
  belongs_to :questionnaire
  has_many :questionnaire_answers, dependent: :destroy  
  validates :pre_question_text, presence: true, if: -> { pre_question_type.present? }
  validates :post_question_text, presence: true, if: -> { post_question_type.present? }
end
