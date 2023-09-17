require 'rails_helper'

RSpec.describe 'Videos::Searches', type: :request do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user_owner) { create(:user_owner) }
  let(:user_staff) { create(:user_staff) }
  let(:viewer) { create(:viewer) }
  let(:organization_viewer) { create(:organization_viewer) }
  let(:video_jan_public_owner) { create(:video_jan_public_owner) }

  before(:each) do
    organization
    system_admin
    user_owner
    user_staff
    viewer
    organization_viewer
    video_jan_public_owner
  end

  describe 'GET #search' do
    describe 'システム管理者が現在のログインユーザー' do
      before(:each) do
        sign_in system_admin
        get videos_search_videos_path
      end

      describe '正常' do
        it '正常値レスポンス' do
          expect(response).to have_http_status '302'
        end
        it 'videos#indexにリダイレクトされる' do
          expect(redirect_to videos_url(organization_id: organization.id))
        end
      end
    end

    describe 'オーナーが現在のログインユーザー' do
      before(:each) do
        sign_in user_owner
        get videos_search_videos_path
      end

      describe '正常' do
        it '正常値レスポンス' do
          expect(response).to have_http_status '302'
        end
        it 'videos#indexにリダイレクトされる' do
          expect(redirect_to videos_url(organization_id: organization.id))
        end
      end
    end

    describe 'スタッフが現在のログインユーザー' do
      before(:each) do
        sign_in user_staff
        get videos_search_videos_path
      end

      describe '正常' do
        it '正常値レスポンス' do
          expect(response).to have_http_status '302'
        end
        it 'videos#indexにリダイレクトされる' do
          expect(redirect_to videos_url(organization_id: organization.id))
        end
      end
    end

    describe '動画視聴者が現在のログインユーザー' do
      before(:each) do
        sign_in viewer
        get videos_search_videos_path
      end

      describe '正常' do
        it '正常値レスポンス' do
          expect(response).to have_http_status '302'
        end
        it 'videos#indexにリダイレクトされる' do
          expect(redirect_to videos_url(organization_id: organization.id))
        end
      end
    end

    describe '非ログイン' do
      before(:each) do
        get videos_search_videos_path
      end

      describe '異常' do
        it '正常値レスポンス' do
          expect(response).to have_http_status '302'
        end
        it 'root_pathにリダイレクトされる' do
          expect(redirect_to root_url)
        end
      end
    end
  end
end
