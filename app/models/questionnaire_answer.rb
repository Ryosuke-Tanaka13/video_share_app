class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire_item
  belongs_to :user, optional: true
  belongs_to :video
end
