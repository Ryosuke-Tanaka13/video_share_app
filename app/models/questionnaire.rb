class Questionnaire < ApplicationRecord
  belongs_to :user

  validate :check_pre_video_questions
  validate :check_post_video_questions

  private

  def check_pre_video_questions
    if pre_video_questionnaire.present?
      questions = JSON.parse(pre_video_questionnaire) rescue []
      if questions.any? { |q| q["text"].blank? }
        errors.add(:pre_video_questionnaire, "に空の質問があります")
      end
    end
  end

  def check_post_video_questions
    if post_video_questionnaire.present?
      questions = JSON.parse(post_video_questionnaire) rescue []
      if questions.any? { |q| q["text"].blank? }
        errors.add(:post_video_questionnaire, "に空の質問があります")
      end
    end
  end
end
