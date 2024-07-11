require 'rails_helper'

RSpec.describe 'Videos::Searches', :js, type: :system do
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
  let(:admin_viewer) { create(:admin_viewer) }
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
    admin_viewer
    another_video_jan_public_another_user_owner
    another_video_feb_private_another_user_staff
    sleep 0.1
  end

  # ログインしているアカウントによって検索機能に違いはない
  # 削除ボタンの出現有無はvideos_spec.rbでテスト済み（検索機能では割愛）
  # テスト動画1月〜5月はそれぞれ2023年各月末最終日23:59までを公開期間としている

  describe '正常（組織内）' do
    describe '動画一覧ページ' do
      describe 'システム管理者' do
        before(:each) do
          sign_in system_admin
          visit videos_path(organization_id: organization.id)
        end

        it 'レイアウト' do
          expect(page).to have_text '検索条件'
          expect(page).to have_field 'search-title'
          expect(page).to have_field 'search-open_period_from'
          expect(page).to have_field 'search-open_period_to'
          expect(page).to have_field 'search-range-all'
          expect(page).to have_field 'search-range-true'
          expect(page).to have_field 'search-range-false'
          expect(page).to have_field 'search-user-name'
          expect(page).to have_button 'リセット'
          expect(page).to have_button '検索'
          expect(page).to have_css('svg.svg-inline--fa.fa-search.fa-w-16') # 虫眼鏡アイコン
          expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
          expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
          expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
          expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
          expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
          expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
          expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
          expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
          expect(page).to have_content 'オーナー削除済み'
        end

        describe 'リセットボタン' do
          it 'フォームがすべてクリアされ、組織内のすべての動画が表示されること' do
            fill_in 'search-title', with: 'テスト動画1月'
            fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
            fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
            choose 'search-range-all'
            fill_in 'search-user-name', with: 'オーナー'
            click_button 'video-form-reset'
            expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
            expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
            expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
            expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
            expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
            expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
            expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
            expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
            expect(page).to have_no_content '該当する動画はありませんでした。'
            expect(page).to have_no_content '件ヒットしました。'
            expect(page).to have_content 'オーナー削除済み'
          end
        end

        describe '検索ボタン' do
          context '満たす動画がある場合' do
            context '検索フォームが未入力の場合' do
              it '組織内のすべての動画が表示されること' do
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '6件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end
            end

            context 'タイトル「テスト動画1月」を入力した場合' do
              it '「テスト動画1月」、「テスト動画1月（論理削除済み）」のみ表示されること' do
                fill_in 'search-title', with: 'テスト動画1月'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end
            end

            context '公開期間開始日時が2023-2-1 0:00場合' do
              it '「テスト動画2〜5月」のみ表示されること' do
                fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '4件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context '公開期間終了日時が2023-1-31 23:59の場合' do
              it '「テスト動画1月」、「テスト動画1月（論理削除済み）」のみ表示されること' do
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end
            end

            context '公開範囲「すべての動画」を選択した場合' do
              it '組織内のすべての動画が表示されること' do
                choose 'search-range-all'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '6件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end
            end

            context '公開範囲「一般公開のみ」を選択した場合' do
              it '「テスト動画1月、1月（論理削除済み）3月、5月」のみ表示されること' do
                choose 'search-range-true'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '4件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end
            end

            context '公開範囲「限定公開のみ」を選択した場合' do
              it '「テスト動画2月、4月」のみ表示されること' do
                choose 'search-range-false'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context '動画投稿者「オーナー」を入力した場合' do
              it '「テスト動画1月、1月（論理削除済み）、2月」のみ表示されること' do
                fill_in 'search-user-name', with: 'オーナー'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '3件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end
            end

            context 'タイトル、公開期間開始日時ともに満たす場合' do
              it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end

              it 'タイトル「テ」を含みかつ2023-2-1 0:00以降を表示すること' do
                fill_in 'search-title', with: 'テ'
                fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '4件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context 'タイトル、公開期間終了日時ともに満たす場合' do
              it 'タイトル「テスト動画1月」かつ2023-1-31 23:59以前の動画を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end

              it 'タイトル「テ」を含みかつ2023-2-28 23:59以前を表示すること' do
                fill_in 'search-title', with: 'テ'
                fill_in 'search-open_period_to', with: DateTime.new(2023, 2, 28, 23, 59)
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '3件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end
            end

            context 'タイトル、公開範囲ともに満たす場合' do
              it 'タイトル「テスト動画1月」かつ「すべての動画」を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                choose 'search-range-all'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end

              it 'タイトル「テスト動画1月」かつ「一般公開のみ」を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                choose 'search-range-true'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end

              it 'タイトル「テスト動画2月」かつ「限定公開のみ」を表示すること' do
                fill_in 'search-title', with: 'テスト動画2月'
                choose 'search-range-false'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context 'タイトル、動画投稿者ともに満たす場合' do
              it 'タイトル「テスト動画1月」かつ動画投稿者「オーナー」を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                fill_in 'search-user-name', with: 'オーナー'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end

              it 'タイトル「テ」を含むかつ動画投稿者「オ」を表示すること' do
                fill_in 'search-title', with: 'テ'
                fill_in 'search-user-name', with: 'オ'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '3件ヒットしました。'
                expect(page).to have_content 'オーナー削除済み'
              end

              context '公開期間、公開範囲ともに満たす場合' do
                it '2023-2-1 0:00以降かつ「すべての動画」を表示すること' do
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
                  choose 'search-range-all'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '4件ヒットしました。'
                  expect(page).to have_no_content 'オーナー削除済み'
                end

                it '2023-1-1 0:00以降かつ「一般公開のみ」を表示すること' do
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                  choose 'search-range-true'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '4件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end

                it '2023-1-1 0:00以降かつ「限定公開のみ」を表示すること' do
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                  choose 'search-range-false'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_no_content 'オーナー削除済み'
                end

                it '2023-1-31 23:59以前かつ「すべての動画」を表示すること' do
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                  choose 'search-range-all'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end

                it '2023-1-31 23:59以前かつ「一般公開のみ」を表示すること' do
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                  choose 'search-range-true'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end

                it '2023-2-28 23:59以前かつ「限定公開のみ」を表示すること' do
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 2, 28, 23, 59)
                  choose 'search-range-false'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '1件ヒットしました。'
                  expect(page).to have_no_content 'オーナー削除済み'
                end
              end

              context '公開期間、動画投稿者ともに満たす場合' do
                it '2023-2-1 0:00以降かつ動画投稿者「オーナー」を表示すること' do
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
                  fill_in 'search-user-name', with: 'オーナー'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '1件ヒットしました。'
                  expect(page).to have_no_content 'オーナー削除済み'
                end

                it '2023-1-31 23:59以前かつ動画投稿者「オ」を表示すること' do
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                  fill_in 'search-user-name', with: 'オ'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end
              end

              context '公開範囲、動画投稿者ともに満たす場合' do
                it '「すべての動画」かつ動画投稿者「オーナー」を表示すること' do
                  choose 'search-range-all'
                  fill_in 'search-user-name', with: 'オーナー'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '3件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end

                it '「一般公開のみ」かつ動画投稿者「オ」を表示すること' do
                  choose 'search-range-true'
                  fill_in 'search-user-name', with: 'オ'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end

                it '「限定公開のみ」かつ動画投稿者「オ」を表示すること' do
                  choose 'search-range-false'
                  fill_in 'search-user-name', with: 'オ'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '1件ヒットしました。'
                  expect(page).to have_no_content 'オーナー削除済み'
                end
              end

              context 'タイトル、公開期間、公開範囲すべてを満たす場合' do
                it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降 2023-1-31 23:59以前かつ「一般公開のみ」を表示すること' do
                  fill_in 'search-title', with: 'テスト動画1月'
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                  choose 'search-range-true'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end
              end

              context 'タイトル、公開期間、動画投稿者すべてを満たす場合' do
                it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降 2023-1-31 23:59以前かつ動画投稿者「オーナー」を表示すること' do
                  fill_in 'search-title', with: 'テスト動画1月'
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                  fill_in 'search-user-name', with: 'オーナー'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end
              end

              context '公開期間、公開範囲、動画投稿者すべてを満たす場合' do
                it '2023-1-1 0:00以降 2023-1-31 23:59以前かつ「一般公開のみ」かつ動画投稿者「オーナー」を表示すること' do
                  choose 'search-range-true'
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                  fill_in 'search-user-name', with: 'オーナー'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end
              end

              context 'タイトル、公開期間、公開範囲、動画投稿者すべてを満たす場合' do
                it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降 2023-1-31 23:59以前かつ「すべての動画」かつ動画投稿者「オーナー」を表示すること' do
                  fill_in 'search-title', with: 'テスト動画1月'
                  fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                  fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                  choose 'search-range-true'
                  fill_in 'search-user-name', with: 'オーナー'
                  click_button 'video-form-submit'
                  expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                  expect(page).to have_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                  expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                  expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                  expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                  expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                  expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                  expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                  expect(page).to have_content '2件ヒットしました。'
                  expect(page).to have_content 'オーナー削除済み'
                end
              end
            end
          end
        end
      end

      describe 'オーナー、スタッフ、動画視聴者' do
        before(:each) do
          sign_in user_owner || user_staff || viewer
          visit videos_path(organization_id: organization.id)
        end

        it 'レイアウト' do
          expect(page).to have_text '検索条件'
          expect(page).to have_field 'search-title'
          expect(page).to have_field 'search-open_period_from'
          expect(page).to have_field 'search-open_period_to'
          expect(page).to have_field 'search-range-all'
          expect(page).to have_field 'search-range-true'
          expect(page).to have_field 'search-range-false'
          expect(page).to have_field 'search-user-name'
          expect(page).to have_button 'リセット'
          expect(page).to have_button '検索'
          expect(page).to have_css('svg.svg-inline--fa.fa-search.fa-w-16') # 虫眼鏡アイコン
          expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
          expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
          expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
          expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
          expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
          expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
          expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
          expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
          expect(page).to have_no_content 'オーナー削除済み'
        end

        describe 'リセット' do
          it 'フォームがすべてクリアされ、組織内のすべての動画が表示されること' do
            fill_in 'search-title', with: 'テスト動画1月'
            fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
            fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
            choose 'search-range-all'
            fill_in 'search-user-name', with: 'オーナー'
            click_button 'video-form-reset'
            expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
            expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
            expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
            expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
            expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
            expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
            expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
            expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
            expect(page).to have_no_content '該当する動画はありませんでした。'
            expect(page).to have_no_content '件ヒットしました。'
            expect(page).to have_no_content 'オーナー削除済み'
          end
        end

        context '満たす動画がある場合' do
          context '検索フォームが未入力の場合' do
            it '組織内のすべての動画が表示されること' do
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '5件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル「テスト動画1月」を入力した場合' do
            it '「テスト動画1月」のみ表示されること' do
              fill_in 'search-title', with: 'テスト動画1月'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間開始日時が2023-2-1 0:00場合' do
            it '「テスト動画2〜5月」のみ表示されること' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '4件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間終了日時が2023-1-31 23:59の場合' do
            it '「テスト動画1月」のみ表示されること' do
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開範囲「すべての動画」を選択した場合' do
            it '組織内のすべての動画が表示されること' do
              choose 'search-range-all'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '5件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開範囲「一般公開のみ」を選択した場合' do
            it '「テスト動画1月、3月、5月」のみ表示されること' do
              choose 'search-range-true'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '3件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開範囲「限定公開のみ」を選択した場合' do
            it '「テスト動画2月、4月」のみ表示されること' do
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '2件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '動画投稿者「オーナー」を入力した場合' do
            it '「テスト動画1月、2月」のみ表示されること' do
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '2件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間開始日時ともに満たす場合' do
            it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降を表示すること' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル「テ」を含みかつ2023-2-1 0:00以降を表示すること' do
              fill_in 'search-title', with: 'テ'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '4件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間終了日時ともに満たす場合' do
            it 'タイトル「テスト動画1月」かつ2023-1-31 23:59以前の動画を表示すること' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル「テ」を含みかつ2023-2-28 23:59以前を表示すること' do
              fill_in 'search-title', with: 'テ'
              fill_in 'search-open_period_to', with: DateTime.new(2023, 2, 28, 23, 59)
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '2件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開範囲ともに満たす場合' do
            it 'タイトル「テスト動画1月」かつ「すべての動画」を表示すること' do
              fill_in 'search-title', with: 'テスト動画1月'
              choose 'search-range-all'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル「テスト動画1月」かつ「一般公開のみ」を表示すること' do
              fill_in 'search-title', with: 'テスト動画1月'
              choose 'search-range-true'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル「テスト動画2月」かつ「限定公開のみ」を表示すること' do
              fill_in 'search-title', with: 'テスト動画2月'
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、動画投稿者ともに満たす場合' do
            it 'タイトル「テスト動画1月」かつ動画投稿者「オーナー」を表示すること' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '1件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル「テ」を含むかつ動画投稿者「オ」を表示すること' do
              fill_in 'search-title', with: 'テ'
              fill_in 'search-user-name', with: 'オ'
              click_button 'video-form-submit'
              expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '2件ヒットしました。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            context '公開期間、公開範囲ともに満たす場合' do
              it '2023-2-1 0:00以降かつ「すべての動画」を表示すること' do
                fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
                choose 'search-range-all'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '4件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '2023-1-1 0:00以降かつ「一般公開のみ」を表示すること' do
                fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                choose 'search-range-true'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '3件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '2023-1-1 0:00以降かつ「限定公開のみ」を表示すること' do
                fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                choose 'search-range-false'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '2023-1-31 23:59以前かつ「すべての動画」を表示すること' do
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                choose 'search-range-all'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '2023-1-31 23:59以前かつ「一般公開のみ」を表示すること' do
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                choose 'search-range-true'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '2023-2-28 23:59以前かつ「限定公開のみ」を表示すること' do
                fill_in 'search-open_period_to', with: DateTime.new(2023, 2, 28, 23, 59)
                choose 'search-range-false'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context '公開期間、動画投稿者ともに満たす場合' do
              it '2023-2-1 0:00以降かつ動画投稿者「オーナー」を表示すること' do
                fill_in 'search-open_period_from', with: DateTime.new(2023, 2, 1, 0, 0)
                fill_in 'search-user-name', with: 'オーナー'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '2023-1-31 23:59以前かつ動画投稿者「オ」を表示すること' do
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                fill_in 'search-user-name', with: 'オ'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context '公開範囲、動画投稿者ともに満たす場合' do
              it '「すべての動画」かつ動画投稿者「オーナー」を表示すること' do
                choose 'search-range-all'
                fill_in 'search-user-name', with: 'オーナー'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '2件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '「一般公開のみ」かつ動画投稿者「オ」を表示すること' do
                choose 'search-range-true'
                fill_in 'search-user-name', with: 'オ'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end

              it '「限定公開のみ」かつ動画投稿者「オ」を表示すること' do
                choose 'search-range-false'
                fill_in 'search-user-name', with: 'オ'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context 'タイトル、公開期間、公開範囲すべてを満たす場合' do
              it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降 2023-1-31 23:59以前かつ「一般公開のみ」を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                choose 'search-range-true'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context 'タイトル、公開期間、動画投稿者すべてを満たす場合' do
              it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降 2023-1-31 23:59以前かつ動画投稿者「オーナー」を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                fill_in 'search-user-name', with: 'オーナー'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context '公開期間、公開範囲、動画投稿者すべてを満たす場合' do
              it '2023-1-1 0:00以降 2023-1-31 23:59以前かつ「一般公開のみ」かつ動画投稿者「オーナー」を表示すること' do
                choose 'search-range-true'
                fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                fill_in 'search-user-name', with: 'オーナー'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end

            context 'タイトル、公開期間、公開範囲、動画投稿者すべてを満たす場合' do
              it 'タイトル「テスト動画1月」かつ2023-1-1 0:00以降 2023-1-31 23:59以前かつ「すべての動画」かつ動画投稿者「オーナー」を表示すること' do
                fill_in 'search-title', with: 'テスト動画1月'
                fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
                fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
                choose 'search-range-all'
                fill_in 'search-user-name', with: 'オーナー'
                click_button 'video-form-submit'
                expect(page).to have_link 'テスト動画1月', href: video_path(video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
                expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
                expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
                expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
                expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
                expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
                expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
                expect(page).to have_content '1件ヒットしました。'
                expect(page).to have_no_content 'オーナー削除済み'
              end
            end
          end
        end
      end

      # 検索結果に該当データがない場合はアカウントによる表示に違いはないのでまとめてテスト
      describe 'システム管理者または動画投稿者または動画視聴者' do
        before(:each) do
          sign_in system_admin || user_owner || user_staff || viewer
          video_jan_public_owner
          invalid_video_jan_public_owner
          video_feb_private_owner
          video_mar_public_staff
          video_apr_private_staff
          video_may_public_staff1
          visit videos_path(organization_id: organization.id)
        end

        context '満たす動画がない場合' do
          context '一致するタイトルがない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間開始日時を満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間終了日時を満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '動画投稿者を満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間開始日時どちらも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間開始日時どちらかのみ満たす場合' do
            it 'タイトルのみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間開始日時のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間終了日時どちらも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間終了日時どちらかのみ満たす場合' do
            it 'タイトルのみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間終了日時のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開範囲どちらかのみ満たす場合' do
            it 'タイトルのみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              choose 'search-range-all'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、動画投稿者どちらも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、動画投稿者どちらかのみ満たす場合' do
            it 'タイトルのみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間開始日時、公開範囲どちらかのみ満たす場合' do
            it '公開期間開始日時のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 5, 1, 0, 0)
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              choose 'search-range-all'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間終了日時、公開範囲どちらかのみ満たす場合' do
            it '公開期間終了日時のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-all'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間開始日時、動画投稿者どちらも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間開始日時、動画投稿者どちらかのみ満たす場合' do
            it '公開期間開始日時のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間終了日時、動画投稿者どちらも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間終了日時、動画投稿者どちらかのみ満たす場合' do
            it '公開期間終了日時のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開範囲、動画投稿者どちらかのみ満たす場合' do
            it '公開範囲のみ満たす場合、動画が表示されないこと' do
              choose 'search-range-all'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '動画投稿者のみ満たす場合、動画が表示されないこと' do
              choose 'search-range-false'
              fill_in 'search-user-name', with: 'スタッフ1'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間、公開範囲いずれも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間、公開範囲いずれかのみ満たす場合' do
            it 'タイトルのみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-all'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル、公開期間のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              choose 'search-range-false'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル、公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画5月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-true'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間、公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              choose 'search-range-true'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間、動画投稿者いずれも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context 'タイトル、公開期間、動画投稿者いずれかのみ満たす場合' do
            it 'タイトルのみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル、公開期間のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it 'タイトル、動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画1月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間、動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間、公開範囲、動画投稿者いずれも満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-false'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開期間、公開範囲、動画投稿者いずれかのみ満たす場合' do
            it '公開期間のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              choose 'search-range-false'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-all'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-false'
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間、公開範囲のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              choose 'search-range-all'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開期間、動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 1, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2023, 1, 31, 23, 59)
              choose 'search-range-false'
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end

            it '公開範囲、動画投稿者のみ満たす場合、動画が表示されないこと' do
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-all'
              fill_in 'search-user-name', with: 'オーナー'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end

          context '公開範囲を除き満たさない場合' do
            it '動画が表示されないこと' do
              fill_in 'search-title', with: 'テスト動画10月'
              fill_in 'search-open_period_from', with: DateTime.new(2023, 6, 1, 0, 0)
              fill_in 'search-open_period_to', with: DateTime.new(2022, 12, 31, 23, 59)
              choose 'search-range-all'
              fill_in 'search-user-name', with: 'オーナー10'
              click_button 'video-form-submit'
              expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
              expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
              expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
              expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
              expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
              expect(page).to have_no_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
              expect(page).to have_no_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
              expect(page).to have_content '該当する動画はありませんでした。'
              expect(page).to have_no_content 'オーナー削除済み'
            end
          end
        end
      end
    end
  end

  describe '異常（組織外）' do
    describe '動画一覧ページ' do
      describe '組織外のアカウント' do
        before(:each) do
          sign_in another_user_owner || another_user_staff || another_viewer
          visit videos_path(organization_id: another_organization.id)
        end

        it 'レイアウト' do
          expect(page).to have_text '検索条件'
          expect(page).to have_field 'search-title'
          expect(page).to have_field 'search-open_period_from'
          expect(page).to have_field 'search-open_period_to'
          expect(page).to have_field 'search-range-all'
          expect(page).to have_field 'search-range-true'
          expect(page).to have_field 'search-range-false'
          expect(page).to have_field 'search-user-name'
          expect(page).to have_button 'リセット'
          expect(page).to have_button '検索'
          expect(page).to have_css('svg.svg-inline--fa.fa-search.fa-w-16') # 虫眼鏡アイコン
          expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
          expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
          expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
          expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
          expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
          expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
          expect(page).to have_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
          expect(page).to have_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
          expect(page).to have_no_content 'オーナー削除済み'
        end

        context '検索フォームが未入力の場合' do
          it '違う組織の動画は表示されない' do
            click_button 'video-form-submit'
            expect(page).to have_no_link 'テスト動画1月', href: video_path(video_jan_public_owner)
            expect(page).to have_no_link 'テスト動画1月（論理削除済み）', href: video_path(invalid_video_jan_public_owner)
            expect(page).to have_no_link 'テスト動画2月', href: video_path(video_feb_private_owner)
            expect(page).to have_no_link 'テスト動画3月', href: video_path(video_mar_public_staff)
            expect(page).to have_no_link 'テスト動画4月', href: video_path(video_apr_private_staff)
            expect(page).to have_no_link 'テスト動画5月', href: video_path(video_may_public_staff1)
            expect(page).to have_link 'テスト動画1月（組織外）', href: video_path(another_video_jan_public_another_user_owner)
            expect(page).to have_link 'テスト動画2月（組織外）', href: video_path(another_video_feb_private_another_user_staff)
            expect(page).to have_content '2件ヒットしました。'
            expect(page).to have_no_content 'オーナー削除済み'
          end
        end
      end
    end
  end
end
