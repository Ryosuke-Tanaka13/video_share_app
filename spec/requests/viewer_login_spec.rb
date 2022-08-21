require 'rails_helper'

describe 'ログイン処理', type: :request do
  let!(:viewer) { FactoryBot.create(:viewer, password: 'password', confirmed_at: Time.now) }

  describe '管理者がログインできることを確認' do
    it do
      get new_viewer_session_path
      expect(response).to have_http_status(:success)
      post viewer_session_path, params: { viewer: { email: viewer.email, password: viewer.password } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to 'http://www.example.com/viewers'
    end
  end
end
