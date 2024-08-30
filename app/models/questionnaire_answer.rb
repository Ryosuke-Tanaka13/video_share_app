class QuestionnaireAnswer < ApplicationRecord
  belongs_to :questionnaire_item
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :video

  def self.for_video_and_user(video_id:, viewer_id:, user_id:)
    answers = where(video_id: video_id)

    # viewer_id が '0' でない場合、その viewer_id で絞り込み
    answers = answers.where(viewer_id: viewer_id) unless viewer_id == '0'
    # user_id が '0' でない場合、その user_id で絞り込み
    answers = answers.where(user_id: user_id) unless user_id == '0'
    answers
  end

  def self.pre_video_answers(answers)
    answers.select { |qa| qa.pre_answers.present? }
  end

  def self.post_video_answers(answers)
    answers.select { |qa| qa.post_answers.present? }
  end
end
