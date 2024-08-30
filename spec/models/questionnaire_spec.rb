require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user_staff) }

  describe 'バリデーション' do
    context 'pre_video_questionnaire に空の質問がある場合' do
      let(:questionnaire) { build(:questionnaire, user: user, pre_video_questionnaire: '[{"text":"", "type":"text", "answers":[], "required":false}]', post_video_questionnaire: '[]') }

      it '無効であり、適切なエラーメッセージがあること' do
        expect(questionnaire).not_to be_valid
        expect(questionnaire.errors[:pre_video_questionnaire]).to include('に空の質問があります')
      end
    end

    context 'post_video_questionnaire に空の質問がある場合' do
      let(:questionnaire) { build(:questionnaire, user: user, pre_video_questionnaire: '[]', post_video_questionnaire: '[{"text":"", "type":"text", "answers":[], "required":false}]') }

      it '無効であり、適切なエラーメッセージがあること' do
        expect(questionnaire).not_to be_valid
        expect(questionnaire.errors[:post_video_questionnaire]).to include('に空の質問があります')
      end
    end

    context 'pre_video_questionnaire と post_video_questionnaire が有効な場合' do
      let(:questionnaire) { build(:questionnaire, user: user, pre_video_questionnaire: '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]', post_video_questionnaire: '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]') }

      it '有効であること' do
        expect(questionnaire).to be_valid
      end
    end
  end
end
