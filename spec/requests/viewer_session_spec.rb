require 'rails_helper'

RSpec.describe 'ViewerSession', type: :request do
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  
  describe '視聴者がログインできることを確認' do
    before(:each) do
      viewer
    end
      
    it do
      get new_viewer_session_path
      expect(response).to have_http_status(:success)
      post viewer_session_path, params: { viewer: { email: viewer.email, password: viewer.password } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to viewer_path(viewer)
    end
  end

  describe '視聴者がログアウトできることを確認' do
    before(:each) do
      viewer
      login_session(viewer)
      current_viewer(viewer)
      get viewer_path(viewer)
    end
      
    it do
      delete destroy_viewer_session_path
      expect(response).to redirect_to 'http://www.example.com/'
    end
  end
end