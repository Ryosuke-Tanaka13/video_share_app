require 'rails_helper'

RSpec.describe 'Videos::Recordings', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
  end

  describe 'GET #new' do
    describe '正常' do
      context 'オーナー' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get new_recording_path
        end

        it 'レスポンスに成功する' do
          expect(response).to have_http_status(:success)
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status :ok
        end
      end

      context 'スタッフ' do
        before(:each) do
          login_session(user_staff)
          current_user(user_staff)
          get new_recording_path
        end

        it 'レスポンスに成功する' do
          expect(response).to have_http_status(:success)
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status :ok
        end
      end
    end

    describe '異常' do
      context 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get new_recording_path
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '視聴者' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
          get new_recording_path
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end
    end
  end
end
