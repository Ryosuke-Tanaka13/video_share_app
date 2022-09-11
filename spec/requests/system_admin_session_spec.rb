require 'rails_helper'

RSpec.describe 'SystemAdminSession', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  
  describe 'システム管理者がログインできることを確認' do
    before(:each) do
      system_admin
    end
      
    it do
      get new_system_admin_session_path
      expect(response).to have_http_status(:success)
      post system_admin_session_path, params: { system_admin: { email: system_admin.email, password: system_admin.password } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to 'http://www.example.com/organizations'
    end
  end

  describe 'システム管理者がログアウトできることを確認' do
    before(:each) do
      system_admin
      login_session(system_admin)
      current_system_admin(system_admin)
      get organizations_path
    end
      
    it do
      delete destroy_system_admin_session_path
      expect(response).to redirect_to 'http://www.example.com/'
    end
  end
end