class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :viewer, optional: true
  belongs_to :video
  belongs_to :user, optional: true

  serialize :pre_questions, YAML
  serialize :post_questions, YAML

  serialize :pre_answers, JSON
  serialize :post_answers, JSON
end
