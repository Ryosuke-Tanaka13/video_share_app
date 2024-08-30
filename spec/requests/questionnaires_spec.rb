require 'rails_helper'

RSpec.describe 'アンケート管理機能', type: :request do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, organization_id: organization.id, confirmed_at: Time.now) }
  let!(:questionnaire) { create(:questionnaire, user: user, pre_video_questionnaire: '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]', post_video_questionnaire: '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]') }
  let(:valid_params) do
    {
      questionnaire: {
        pre_video_questionnaire:  '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]',
        post_video_questionnaire: '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]'
      }
    }
  end

  let(:invalid_params) do
    {
      questionnaire: {
        pre_video_questionnaire:  '[{"text":"", "type":"text", "answers":[], "required":false}]',
        post_video_questionnaire: '[{"text":"", "type":"text", "answers":[], "required":false}]'
      }
    }
  end

  describe 'GET /new' do
    it '新規作成ページに正常にアクセスできること' do
      sign_in user
      get new_user_questionnaire_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /create' do
    context '有効なパラメータの場合' do
      it '新しいアンケートを作成できること' do
        sign_in user
        expect {
          post user_questionnaires_path(user), params: valid_params
        }.to change(Questionnaire, :count).by(1)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['redirect']).to eq(user_questionnaires_path(user))
      end
    end

    context '無効なパラメータの場合' do
      it '新しいアンケートを作成できず、エラーメッセージが表示されること' do
        sign_in user
        expect {
          post user_questionnaires_path(user), params: invalid_params
        }.not_to change(Questionnaire, :count)
        json_response = JSON.parse(response.body)
        expect(json_response['redirect']).to eq(new_user_questionnaire_path(user))
        expect(flash[:danger]).to eq('エラーが発生しました。質問を入力してください')
      end
    end
  end

  describe 'GET /edit' do
    it '編集ページに正常にアクセスできること' do
      sign_in user
      get edit_user_questionnaire_path(user, questionnaire)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /update' do
    context '有効なパラメータの場合' do
      it 'アンケートを更新できること' do
        sign_in user
        patch user_questionnaire_path(user, questionnaire), params: { questionnaire: { pre_video_questionnaire: '[{"text":"更新された質問", "type":"text", "answers":[], "required":false}]', post_video_questionnaire: '[{"text":"更新された質問", "type":"text", "answers":[], "required":false}]' } }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['redirect']).to eq(user_questionnaires_path(user))
        questionnaire.reload
        expect(questionnaire.pre_video_questionnaire).to include('更新された質問')
      end
    end

    context '無効なパラメータの場合' do
      it 'アンケートが更新されず、エラーメッセージが表示されること' do
        sign_in user
        patch user_questionnaire_path(user, questionnaire), params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response['redirect']).to eq(edit_user_questionnaire_path(user, questionnaire))
        expect(flash[:danger]).to eq('編集内容が無効です。質問を入力してください')
        questionnaire.reload
        expect(questionnaire.pre_video_questionnaire).not_to include('更新された質問')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'アンケートを削除できること' do
      sign_in user
      expect {
        delete user_questionnaire_path(user, questionnaire)
        follow_redirect!
      }.to change(Questionnaire, :count).by(-1)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('アンケートが削除されました。')
    end
  end
end
