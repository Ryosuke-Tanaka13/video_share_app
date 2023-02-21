require 'rails_helper'

RSpec.describe 'ViewerSession', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }
  let(:deactivated_viewer) { create(:deactivated_viewer, confirmed_at: Time.now) }
  let(:same_email_viewer) { create(:same_email_viewer, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }

  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer1) { create(:organization_viewer1) }
  let(:organization_viewer2) { create(:organization_viewer2) }
  let(:organization_viewer3) { create(:organization_viewer3) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    deactivated_viewer
    same_email_viewer
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    organization_viewer
    organization_viewer1
    organization_viewer2
    organization_viewer3
  end

  describe '正常' do
    context '視聴者がログインできることを確認' do
      it do
        get new_viewer_session_path
        expect(response).to have_http_status(:success)
        post viewer_session_path, params: { viewer: { email: viewer.email, password: viewer.password } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to 'http://www.example.com/viewers/1'
      end
    end

    context '論理削除と同じメールを使いまわせることを確認' do
      it do
        get new_viewer_session_path
        expect(response).to have_http_status(:success)
        post viewer_session_path, params: { viewer: { email: same_email_viewer.email, password: same_email_viewer.password } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to 'http://www.example.com/viewers/5'
      end
    end

    context '視聴者がログアウトできることを確認' do
      before(:each) do
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

  describe '異常' do
    context '他モデルアカウントとの重複ログインができない' do
      context 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
        end

        it do
          get new_viewer_session_path
          expect(response).to redirect_to 'http://www.example.com/'
        end
      end

      context '投稿者' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
        end

        it do
          get new_viewer_session_path
          expect(response).to redirect_to 'http://www.example.com/'
        end
      end
    end

    context '退会アカウントはログインできないこと' do
      it do
        get new_viewer_session_path
        expect(response).to have_http_status(:success)
        post viewer_session_path, params: { viewer: { email: deactivated_viewer.email, password: deactivated_viewer.password } }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template :new
      end
    end
  end
end
