require 'rails_helper'

RSpec.describe QuestionnaireAnswer, type: :model do
  let(:video) { create(:video_it) }
  let(:required_questionnaire_item) { create(:questionnaire_item, :required, video: video) }
  let(:optional_questionnaire_item) { create(:questionnaire_item, video: video, required: false) }

  let(:valid_attributes) do
    {
      video_id: video.id,
      questionnaire_item_id: required_questionnaire_item.id,
      viewer_name: 'テストユーザー',
      viewer_email: 'test@example.com',
      pre_answers: { required_questionnaire_item.id.to_s => '有効な回答' },
      post_answers: { required_questionnaire_item.id.to_s => '有効な回答' }
    }
  end

  describe 'バリデーション' do
    context '回答が必須のとき' do
      it '回答が空の場合は無効で、エラーメッセージが表示される' do
        questionnaire_answer = QuestionnaireAnswer.new(valid_attributes.merge(pre_answers: { required_questionnaire_item.id.to_s => '' }))
        expect(questionnaire_answer).not_to be_valid
        expect(questionnaire_answer.errors[:pre_answers]).to include('回答に不備があります。※は必須項目です。')
      end

      it '回答が正常に保存される' do
        questionnaire_answer = QuestionnaireAnswer.new(valid_attributes)
        expect(questionnaire_answer).to be_valid
      end
    end

    context '回答が必須でないとき' do
      it '空の状態でも保存可能である' do
        questionnaire_answer = QuestionnaireAnswer.new(valid_attributes.merge(questionnaire_item_id: optional_questionnaire_item.id, pre_answers: { optional_questionnaire_item.id.to_s => '' }))
        expect(questionnaire_answer).to be_valid
      end
    end
  end
end
