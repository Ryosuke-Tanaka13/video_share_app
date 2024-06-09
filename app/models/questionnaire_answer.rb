class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :viewer, optional: true
  belongs_to :video
  belongs_to :user, optional: true

  serialize :pre_questions, JSON
  serialize :post_questions, JSON

  serialize :pre_answers, JSON
  serialize :post_answers, JSON
end
