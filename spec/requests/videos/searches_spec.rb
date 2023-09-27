require 'rails_helper'

RSpec.describe 'Videos::Searches', type: :request do
  # 組織内
  let(:organization) { create(:organization) }
  # confirmed_at: 認証しないとログインできないため付与
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_staff1) { create(:user_staff1, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:organization_viewer) { create(:organization_viewer) }
  let(:video_jan_public_owner) { create(:video_jan_public_owner) }
  let(:invalid_video_jan_public_owner) { create(:invalid_video_jan_public_owner) }
  let(:video_feb_private_owner) { create(:video_feb_private_owner) }
  let(:video_mar_public_staff) { create(:video_mar_public_staff) }
  let(:video_apr_private_staff) { create(:video_apr_private_staff) }
  let(:video_may_public_staff1) { create(:video_may_public_staff1) }

  # 組織外
  let(:another_organization) { create(:another_organization) }
  # confirmed_at: 認証しないとログインできないため付与
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }
  let(:organization_viewer1) { create(:organization_viewer1) }
  let(:another_video_jan_public_another_user_owner) { create(:another_video_jan_public_another_user_owner) }
  let(:another_video_feb_private_another_user_staff) { create(:another_video_feb_private_another_user_staff) }

  before(:each) do
    # 組織内
    organization
    system_admin
    user_owner
    user_staff
    user_staff1
    viewer
    organization_viewer
    video_jan_public_owner
    invalid_video_jan_public_owner
    video_feb_private_owner
    video_mar_public_staff
    video_apr_private_staff
    video_may_public_staff1

    # 組織外
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    organization_viewer1
    another_video_jan_public_another_user_owner
    another_video_feb_private_another_user_staff
  end

  describe 'GET #search' do
    describe '正常' do
      context 'システム管理者が現在のログインユーザーの場合' do
        before(:each) do
          sign_in system_admin
          get videos_path(organization_id: organization.id)
        end

        context '満たす動画がある場合' do
          context 'タイトルのみ入力した場合' do
            it 'タイトルを満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間のみ入力する場合' do
            it '公開期間を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間のみ入力する場合' do
            it '公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '動画投稿者のみ入力する場合' do
            it '動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間のみ入力する場合' do
            it 'タイトル、公開期間を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開範囲のみ入力する場合' do
            it 'タイトル、公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、動画投稿者のみ入力する場合' do
            it 'タイトル、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲のみ入力する場合' do
            it '公開期間、公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、動画投稿者のみ入力する場合' do
            it '公開期間、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開範囲、動画投稿者のみ入力する場合' do
            it '公開範囲、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'true',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、公開範囲のみ入力する場合' do
            it 'タイトル、公開期間、公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、動画投稿者のみ入力する場合' do
            it 'タイトル、公開期間、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲、動画投稿者のみ入力する場合' do
            it '公開期間、公開範囲、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、公開範囲、動画投稿者を入力する場合' do
            it 'タイトル、公開期間、公開範囲、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end
        end

        context '満たす動画がない場合' do
          context 'タイトルのみ入力する場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間のみ入力する場合' do
            it '公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '動画投稿者のみ入力する場合' do
            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間ともに満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間どちらかを満たさない場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開範囲どちらかを満たさない場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、動画投稿者ともに満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、動画投稿者どちらかを満たさない場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲どちらかを満たさない場合' do
            it '公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、動画投稿者ともに満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、動画投稿者どちらかを満たさない場合' do
            it '公開期間満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開範囲、動画投稿者どちらかを満たさない場合' do
            it '公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'false',
                  user_name: 'スタッフ1'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end
          
          context 'タイトル、公開期間、公開範囲いずれかを満たさない場合' do
            it 'タイトルのみを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間のみを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲のみを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間、公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、動画投稿者いずれも満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、動画投稿者いずれかを満たさない場合' do
            it 'タイトルのみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲、動画投稿者いずれかを満たさない場合' do
            it '公開期間のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間、公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2023-06-30T23:59',
                  range: 'false',
                  user_name: 'スタッフ1'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2023-06-30T23:59',
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開範囲を除きいずれも満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end
        end
      end

      context 'オーナー、スタッフ、動画視聴者が現在のログインユーザーの場合' do
        before(:each) do
          sign_in user_owner || user_staff || viewer
          get videos_path(organization_id: organization.id)
        end

        context '満たす動画がある場合' do
          context 'タイトルのみ入力した場合' do
            it 'タイトルを満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間のみ入力する場合' do
            it '公開期間を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間のみ入力する場合' do
            it '公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '動画投稿者のみ入力する場合' do
            it '動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間のみ入力する場合' do
            it 'タイトル、公開期間を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開範囲のみ入力する場合' do
            it 'タイトル、公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、動画投稿者のみ入力する場合' do
            it 'タイトル、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲のみ入力する場合' do
            it '公開期間、公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、動画投稿者のみ入力する場合' do
            it '公開期間、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開範囲、動画投稿者のみ入力する場合' do
            it '公開範囲、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'true',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、公開範囲のみ入力する場合' do
            it 'タイトル、公開期間、公開範囲を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、動画投稿者のみ入力する場合' do
            it 'タイトル、公開期間、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲、動画投稿者のみ入力する場合' do
            it '公開期間、公開範囲、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、公開範囲、動画投稿者を入力する場合' do
            it 'タイトル、公開期間、公開範囲、動画投稿者を満たす動画を取得すること' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end
        end

        context '満たす動画がない場合' do
          context 'タイトルのみ入力する場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間のみ入力する場合' do
            it '公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '動画投稿者のみ入力する場合' do
            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間ともに満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間どちらかを満たさない場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開範囲どちらかを満たさない場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、動画投稿者ともに満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、動画投稿者どちらかを満たさない場合' do
            it 'タイトルを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲どちらかを満たさない場合' do
            it '公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、動画投稿者ともに満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、動画投稿者どちらかを満たさない場合' do
            it '公開期間満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開範囲、動画投稿者どちらかを満たさない場合' do
            it '公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'false',
                  user_name: 'スタッフ1'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end
          
          context 'タイトル、公開期間、公開範囲いずれかを満たさない場合' do
            it 'タイトルのみを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間のみを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲のみを満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、動画投稿者いずれも満たさない場合' do
            it '動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context 'タイトル、公開期間、動画投稿者いずれかを満たさない場合' do
            it 'タイトルのみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、公開期間を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it 'タイトル、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画1月',
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開期間、公開範囲、動画投稿者いずれかを満たさない場合' do
            it '公開期間のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false',
                  user_name: 'オーナー'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '動画投稿者のみ満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'true',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間、公開範囲を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2023-06-30T23:59',
                  range: 'false',
                  user_name: 'スタッフ1'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開期間、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2023-06-30T23:59',
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end

            it '公開範囲、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  open_period_from: '2023-01-01T00:00',
                  open_period_to: '2023-01-31T23:59',
                  range: 'false',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end

          context '公開範囲を除きいずれも満たさない場合' do
            it '公開範囲、動画投稿者を満たさない場合、動画を取得しないこと' do
              get videos_search_videos_path, params: {
                search: {
                  title_like: 'テスト動画10月',
                  open_period_from: '2023-06-01T00:00',
                  open_period_to: '2022-12-31T23:59',
                  range: 'all',
                  user_name: 'オーナー10'
                }
              }
              expect(response).to have_http_status(:success)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（論理削除済み）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画3月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画4月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画5月<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画1月（組織外）<\/a>/i)
              expect(response.body).to_not match(/<a [^>]*href=['"][^'"]+['"][^>]*>テスト動画2月（組織外）<\/a>/i)
            end
          end
        end
      end
    end

    describe '異常' do
      context '非ログインの場合' do
        before(:each) do
          get videos_search_videos_path
        end
  
        it '正常値レスポンス' do
          expect(response).to have_http_status '302'
        end

        it 'root_pathにリダイレクトされる' do
          expect(response).to redirect_to root_url
        end
      end
    end
  end
end
