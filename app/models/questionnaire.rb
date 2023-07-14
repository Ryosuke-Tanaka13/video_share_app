class Questionnaire < ApplicationRecord
  include ActiveModel::Conversion
  validates :content, presence: true  # 空のデータをはじくバリデーション

  has_many :questionnaire_items, dependent: :destroy  # アソシエーション ＋ postレコードを削除したときに紐づいたtagを同時に削除
  accepts_nested_attributes_for :questionnaire_items, allow_destroy: true  # fields_for（後述）に必要
end