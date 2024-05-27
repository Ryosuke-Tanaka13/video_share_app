class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :viewer
  belongs_to :video
  serialize :answers, JSON
end
