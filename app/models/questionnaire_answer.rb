class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :viewer, optional: true
  belongs_to :video
  belongs_to :user, optional: true
end
