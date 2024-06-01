class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :viewer, optional: true
  belongs_to :video
  belongs_to :user, optional: true

  serialize :pre_questions, Array
  serialize :post_questions, Array
end
