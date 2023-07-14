class QuestionnaireItem < ApplicationRecord
    validates :content, presence: true  # 空のデータをはじくバリデーション
  
    belongs_to :questionnaire  # アソシエーション
end