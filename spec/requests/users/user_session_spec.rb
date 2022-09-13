require 'rails_helper'

RSpec.describe 'UserSession', type: :request do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }

  describe 'オーナーがログインできることを確認' do
    before(:each) do
      organization
      user_owner
    end

    it do
      get new_user_session_path
      expect(response).to have_http_status(:success)
      post user_session_path, params: { user: { email: user_owner.email, password: user_owner.password } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to 'http://www.example.com/users'
    end
  end

  describe 'オーナーがログアウトできることを確認' do
    before(:each) do
      organization
      user_owner
      login_session(user_owner)
      current_user(user_owner)
      get users_path(user_owner)
    end

    it do
      delete destroy_user_session_path
      expect(response).to redirect_to 'http://www.example.com/'
    end
  end

  describe 'スタッフがログインできることを確認' do
    before(:each) do
      organization
      user
    end

    it do
      get new_user_session_path
      expect(response).to have_http_status(:success)
      post user_session_path, params: { user: { email: user.email, password: user.password } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to 'http://www.example.com/users'
    end
  end

  describe 'スタッフがログアウトできることを確認' do
    before(:each) do
      organization
      user_owner
      login_session(user)
      current_user(user)
      get users_path(user)
    end

    it do
      delete destroy_user_session_path
      expect(response).to redirect_to 'http://www.example.com/'
    end
  end
end
