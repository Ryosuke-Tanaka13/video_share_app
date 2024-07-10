require 'rails_helper'

RSpec.xdescribe 'VideosSystem', :js, type: :system do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }
  # orgにのみ属す
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }

  let(:video_sample) do
    create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id, folders: [folder_celeb, folder_tech])
  end
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb]) }
  let(:video_it) { create(:video_it, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  # orgとviewerの紐付け
  let(:organization_viewer) { create(:organization_viewer) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    video_sample
    video_test
    folder_celeb
    folder_tech
    organization_viewer
  end

  describe '正常' do
    describe '動画一覧ページ' do
      before(:each) do
        sign_in system_admin
        video_sample
        video_test
        visit videos_path(organization_id: organization.id)
      end

      it 'レイアウト' do
        expect(page).to have_link 'サンプルビデオ', href: video_path(video_sample)
        expect(page).to have_link '削除', href: video_path(video_sample)
        expect(page).to have_link 'テストビデオ', href: video_path(video_test)
        expect(page).to have_link '削除', href: video_path(video_test)
      end

      it '動画削除' do
        find(:xpath, '//*[@id="videos-index"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はvimeoからも完全に削除されます'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '削除しました'
        }.to change(Video, :count).by(-1)
      end

      it '動画削除キャンセル' do
        find(:xpath, '//*[@id="videos-index"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はvimeoからも完全に削除されます'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Video, :count)
      end
    end

    describe '動画詳細' do
      before(:each) do
        sign_in user_owner || system_admin
        visit video_path(video_test)
      end

      it 'レイアウト' do
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_link '設定'
        expect(page).to have_link '削除'
      end
    end

    describe 'モーダル画面' do
      before(:each) do
        sign_in system_admin || user_owner || user_staff
        visit video_path(video_test)
        click_link('設定')
      end

      it 'モーダルが表示されていること' do
        expect(page).to have_selector('.modal')
      end

      it 'レイアウト' do
        expect(page).to have_button '設定を変更'
        expect(page).to have_button '閉じる'
        expect(page).to have_field 'title_edit', with: video_test.title
        expect(page).to have_field 'open_period_edit', with: '2022-08-14T18:06'
        expect(page).to have_select('range_edit', selected: '一般公開')
        expect(page).to have_select('comment_public_edit', selected: '公開')
        expect(page).to have_select('login_set_edit', selected: 'ログイン不要')
        expect(page).to have_select('popup_before_video_edit', selected: '動画視聴開始時ポップアップ表示')
        expect(page).to have_select('popup_after_video_edit', selected: '動画視聴終了時ポップアップ表示')
        expect(page).to have_field 'セレブエンジニア'
        expect(page).to have_field 'テックリーダーズ'
      end

      it '設定を変更で動画情報が更新される' do
        fill_in 'title_edit', with: 'テストビデオ２'
        # fill_in 'open_period_edit', with: 'Sun, 14 Aug 2022 18:07:00.000000000 JST +09:00'
        select '限定公開', from: 'range_edit'
        select '非公開', from: 'comment_public_edit'
        select 'ログイン必要', from: 'login_set_edit'
        select '動画視聴開始時ポップアップ非表示', from: 'popup_before_video_edit'
        select '動画視聴終了時ポップアップ非表示', from: 'popup_after_video_edit'
        check 'video_folder_ids_2'
        click_button '設定を変更'
        expect(page).to have_text '動画情報を更新しました'
      end
    end

    describe '動画投稿画面' do
      before(:each) do
        sign_in user_owner || user_staff
        visit new_video_path
      end

      it 'レイアウト' do
        expect(page).to have_button '新規投稿'
        expect(page).to have_field 'title'
        expect(page).to have_field 'post'
        expect(page).to have_field 'open_period'
        expect(page).to have_selector '#range'
        expect(page).to have_selector '#comment_public'
        expect(page).to have_selector '#login_set'
        expect(page).to have_selector '#popup_before_video'
        expect(page).to have_selector '#popup_after_video'
        expect(page).to have_field 'セレブエンジニア'
        expect(page).to have_field 'テックリーダーズ'
        expect(page).to have_link 'フォルダ新規作成はこちら'
      end

      # videosのインスタンス生成に必要なdata_urlの入力方法がわからず、テスト実施できず
      # it '新規作成で動画が作成される' do
      #   fill_in 'title', with: 'サンプルビデオ２'
      #   attach_file 'video[video]', File.join(Rails.root, 'spec/fixtures/files/rec.webm')
      #   fill_in 'open_period', with: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00'
      #   select '限定公開', from: 'range'
      #   select '非公開', from: 'comment_public'
      #   select 'ログイン必要', from: 'login_set'
      #   select '動画視聴開始時ポップアップ非表示', from: 'popup_before_video'
      #   select '動画視聴終了時ポップアップ非表示', from: 'popup_after_video'
      #   check "video_folder_ids_1"
      #   click_button '新規投稿'
      #   expect(page).to have_current_path video_path(Video.last), ignore_query: true
      #   expect(page).to have_text '動画を投稿しました'
      # end
    end
  end

  describe '異常' do
    describe '動画投稿画面' do
      before(:each) do
        sign_in user_owner
        video_test
        visit new_video_path
      end

      it 'タイトル空白' do
        fill_in 'title', with: ''
        attach_file 'video[video]', File.join(Rails.root, 'spec/fixtures/files/rec.webm')
        click_button '新規投稿'
        expect(page).to have_text 'タイトルを入力してください'
      end

      it 'タイトル重複' do
        fill_in 'title', with: 'テストビデオ'
        attach_file 'video[video]', File.join(Rails.root, 'spec/fixtures/files/rec.webm')
        click_button '新規投稿'
        expect(page).to have_text 'タイトルはすでに存在します'
      end

      it '動画データ空白' do
        fill_in 'title', with: 'サンプルビデオ2'
        click_button '新規投稿'
        expect(page).to have_text 'ビデオをアップロードしてください'
      end

      it '動画以外のファイル' do
        fill_in 'title', with: 'サンプルビデオ2'
        attach_file 'video[video]', File.join(Rails.root, 'spec/fixtures/files/default.png')
        click_button '新規投稿'
        expect(page).to have_text 'ビデオをアップロードしてください'
      end
    end

    describe 'モーダル画面' do
      before(:each) do
        sign_in user_owner
        video_sample
        visit video_path(video_test)
        click_link('設定')
      end

      it 'タイトル重複' do
        fill_in 'title_edit', with: 'サンプルビデオ'
        click_button '設定を変更'
        expect(page).to have_text 'タイトルはすでに存在します'
      end

      it 'タイトル空白' do
        fill_in 'title_edit', with: ''
        click_button '設定を変更'
        expect(page).to have_text 'タイトルを入力してください'
      end
    end

    describe '動画一覧画面(オーナー、動画投稿者)' do
      before(:each) do
        sign_in user_owner || user
        video_test
        visit videos_path(organization_id: organization.id)
      end

      it 'レイアウトに削除リンクなし' do
        expect(page).to have_link 'テストビデオ', href: video_path(video_test)
        expect(page).to have_no_link '削除', href: video_path(video_test)
      end
    end

    describe '動画一覧画面(視聴者)' do
      before(:each) do
        sign_in viewer
        video_test
        visit videos_path(organization_id: organization.id)
      end

      it 'レイアウトに設定リンク、削除リンクなし' do
        expect(page).to have_link 'テストビデオ', href: video_path(video_test)
        expect(page).to have_no_link '設定', href: edit_video_path(video_test)
        expect(page).to have_no_link '削除', href: video_path(video_test)
      end
    end

    describe 'モーダル画面(システム管理者、オーナー、動画投稿者本人以外)' do
      before(:each) do
        sign_in user_staff
        visit video_path(video_it)
        click_link('設定')
      end

      it 'モーダルが表示されていること' do
        expect(page).to have_selector('.modal')
      end

      it 'レイアウトに設定を変更リンクなし' do
        expect(page).to have_no_link '設定を変更'
        expect(page).to have_button '閉じる'
        expect(page).to have_field 'title_edit'
        expect(page).to have_field 'open_period_edit'
        expect(page).to have_selector '#range_edit'
        expect(page).to have_selector '#comment_public_edit'
        expect(page).to have_selector '#login_set_edit'
        expect(page).to have_selector '#popup_before_video_edit'
        expect(page).to have_selector '#popup_after_video_edit'
        expect(page).to have_field 'セレブエンジニア'
        expect(page).to have_field 'テックリーダーズ'
      end
    end

    describe '動画詳細(動画投稿者)' do
      before(:each) do
        sign_in user_staff
        visit video_path(video_test)
      end

      it 'レイアウトに論理削除リンクなし' do
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_no_link '削除'
      end
    end

    describe '動画詳細(視聴者)' do
      before(:each) do
        sign_in viewer
        visit video_path(video_test)
      end

      it 'レイアウトに設定リンクと論理削除リンクなし' do
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_no_link '設定'
        expect(page).to have_no_link '削除'
      end
    end

    describe '動画詳細(非ログイン)' do
      before(:each) do
        visit video_path(video_test)
      end

      it 'レイアウトに設定リンクと論理削除リンクなし' do
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_no_link '設定'
        expect(page).to have_no_link '削除'
      end
    end
  end
end
