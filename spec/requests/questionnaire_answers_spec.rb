require 'rails_helper'

RSpec.describe "QuestionnaireAnswers", type: :request do
  let(:video) { create(:video_it) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:required_questionnaire_item) { create(:questionnaire_item, :required, video: video) }
  let(:optional_questionnaire_item) { create(:questionnaire_item, video: video, required: false) }
  let(:valid_attributes) do
    {
      video_id: video.id,
      questionnaire_item_id: required_questionnaire_item.id,
      viewer_name: 'テストユーザー',
      viewer_email: 'test@example.com',
      answers: { required_questionnaire_item.id.to_s => '有効な回答' }
    }
  end
  let!(:questionnaire_answer) { create(:questionnaire_answer, video: video, questionnaire_item: required_questionnaire_item, viewer: viewer) }

  before do
    sign_in viewer
  end

  describe 'POST /questionnaire_answers' do
    context '必須質問が未回答の場合' do
      it 'エラーメッセージが表示され、質問フォームが再表示される' do
        post video_questionnaire_answers_path(video), params: { questionnaire_answer: valid_attributes.merge(answers: { required_questionnaire_item.id.to_s => '' }), questionnaire_type: 'pre_video' }
        expect(response.body).to include('回答に不備があります。※は必須項目です。')
        expect(response).to render_template('videos/_popup_before')
      end
    end

    context '回答が正常に保存される場合' do
      it '正常に保存される' do
        post video_questionnaire_answers_path(video), params: { questionnaire_answer: valid_attributes, questionnaire_type: 'pre_video' }
        expect(response).to redirect_to(video_path(video, answered: true))
        follow_redirect!
        expect(flash[:success]).to eq('回答が送信されました。')
      end
    end

    context '任意質問が未回答の場合' do
      it '空の状態でも保存可能である' do
        valid_attributes[:questionnaire_item_id] = optional_questionnaire_item.id
        valid_attributes[:answers] = { optional_questionnaire_item.id.to_s => '' }
        post video_questionnaire_answers_path(video), params: { questionnaire_answer: valid_attributes, questionnaire_type: 'pre_video' }
        expect(response).to redirect_to(video_path(video, answered: true))
        follow_redirect!
        expect(flash[:success]).to eq('回答が送信されました。')
      end
    end

    context '不正なパラメータが送信された場合' do
      it 'エラーメッセージが表示され、リダイレクトされる' do
        post video_questionnaire_answers_path(video), params: { questionnaire_answer: valid_attributes.merge(answers: { '999' => '不正な回答' }), questionnaire_type: 'pre_video' }
        expect(flash[:error]).to eq('Questionnaire item not found')
        expect(response).to redirect_to(video_path(video))
      end
    end
  end

  describe 'DELETE /questionnaire_answers/:id' do
    context '回答の削除が成功する場合' do
      it '回答が削除され、成功メッセージが表示される' do
        expect {
          delete video_questionnaire_answer_path(video, questionnaire_answer)
        }.to change(QuestionnaireAnswer, :count).by(-1)
        expect(flash[:success]).to eq('回答が削除されました。')
        expect(response).to redirect_to(video_questionnaire_answers_path(video))
      end
    end

    context '回答の削除が失敗する場合' do
      before do
        allow_any_instance_of(QuestionnaireAnswer).to receive(:destroy).and_return(false)
      end

      it '回答が削除されず、エラーメッセージが表示される' do
        expect {
          delete video_questionnaire_answer_path(video, questionnaire_answer)
        }.not_to change(QuestionnaireAnswer, :count)
        expect(flash[:danger]).to eq('回答の削除に失敗しました。')
        expect(response).to redirect_to(video_questionnaire_answers_path(video))
      end
    end
  end
end
