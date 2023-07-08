require 'rails_helper'

RSpec.xdescribe 'UserSession', type: :request do
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
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    organization_viewer
    organization_viewer1
    organization_viewer2
    organization_viewer3
  end

  xdescribe '正常' do
    context 'オーナーがログインできることを確認' do
      it do
        get new_user_session_path
        expect(response).to have_http_status(:success)
        post user_session_path, params: { user: { email: user_owner.email, password: user_owner.password } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to 'http://www.example.com/organizations/1/folders'
      end
    end

    context 'オーナーがログアウトできることを確認' do
      before(:each) do
        login_session(user_owner)
        current_user(user_owner)
        get users_path(user_owner)
      end

      it do
        delete destroy_user_session_path
        expect(response).to redirect_to 'http://www.example.com/'
      end
    end

    context 'スタッフがログインできることを確認' do
      it do
        get new_user_session_path
        expect(response).to have_http_status(:success)
        post user_session_path, params: { user: { email: user_staff.email, password: user_staff.password } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to 'http://www.example.com/organizations/1/folders'
      end
    end

    context 'スタッフがログアウトできることを確認' do
      before(:each) do
        login_session(user_staff)
        current_user(user_staff)
        get users_path(user_staff)
      end

      it do
        delete destroy_user_session_path
        expect(response).to redirect_to 'http://www.example.com/'
      end
    end
  end

  xdescribe '異常' do
    context '他モデルアカウントとの重複ログインができない' do
      context 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
        end

        it do
          get new_user_session_path
          expect(response).to redirect_to 'http://www.example.com/'
        end
      end

      context '視聴者' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
        end

        it do
          get new_user_session_path
          expect(response).to redirect_to 'http://www.example.com/'
        end
      end
    end
  end
end
