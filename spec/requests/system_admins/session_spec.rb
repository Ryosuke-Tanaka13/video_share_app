require 'rails_helper'

RSpec.describe 'SystemAdminSession', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }

  let(:organization_viewer) { create(:organization_viewer) }
  let(:admin_viewer) { create(:admin_viewer) }
  let(:member_viewer) { create(:member_viewer) }
  let(:guest_viewer) { create(:guest_viewer) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    organization_viewer
    admin_viewer
    member_viewer
    guest_viewer
  end

  describe '正常' do
    describe 'システム管理者がログインできることを確認' do
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

  describe '異常' do
    describe '他モデルアカウントとの重複ログインができない' do
      context '投稿者' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
        end

        it do
          get new_system_admin_session_path
          expect(response).to redirect_to 'http://www.example.com/'
        end
      end

      context '視聴者' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
        end

        it do
          get new_system_admin_session_path
          expect(response).to redirect_to 'http://www.example.com/'
        end
      end
    end
  end
end
