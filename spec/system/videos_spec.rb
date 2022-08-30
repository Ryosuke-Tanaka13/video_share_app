require 'rails_helper'

RSpec.xdescribe 'VideosSystem', type: :system, js: true do
  let(:organization) { create(:organization) }
  let(:another_organization) { create(:another_organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id, confirmed_at: Time.now) }
  let(:user) { create(:user, organization_id: organization.id, confirmed_at: Time.now) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }
  let(:video_other_owner) do
    create(:video_other_owner, organization_id: another_user_owner.organization.id, user_id: another_user_owner.id)
  end

  before(:each) do
    organization
    another_organization
    user_owner
    another_user_owner
    user
    video_sample
    video_other_owner
  end

  describe '正常(オーナー)' do
    describe '動画一覧ページ' do
      before(:each) do
        sign_in user_owner
        visit videos_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'サンプルビデオ', href: video_path(video_sample)
        expect(page).to have_link '削除', href: video_path(video_sample)
      end

      it '動画削除' do
        find(:xpath, '/html/body/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '動画を削除しました'
        }.to change(Video, :count).by(-1)
      end

      it '動画削除キャンセル' do
        find(:xpath, '/html/body/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Video, :count)
      end
    end

    describe '動画詳細' do
      before(:each) do
        visit video_path(video_sample)
      end

      it 'レイアウト' do
        expect(page).to have_text 'サンプルビデオ'
      end
    end

    describe '動画投稿画面' do
      before(:each) do
        sign_in user_owner
        visit new_video_path
      end

      it 'レイアウト' do
        expect(page).to have_button '新規投稿'
        expect(page).to have_field 'title'
        expect(page).to have_field 'post'
        expect(page).to have_selector '#range'
        expect(page).to have_selector '#comment_public'
        expect(page).to have_selector '#popup_before_video'
        expect(page).to have_selector '#popup_after_video'
      end

      it '新規作成で動画が作成される' do
        # fill_inの値は、ビューのフォームのfieldのid
        fill_in 'title', with: 'サンプルビデオ２'
        # spec/fixtures/filesフォルダに入れたビデオをアップロード
        attach_file 'video[video]', File.join(Rails.root, 'spec/fixtures/files/画面収録 2022-08-30 3.57.50.mov')
        fill_in 'open_period', with: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00'
        expect(page).to have_selector '#range', text: false
        expect(page).to have_selector '#comment_public', text: false
        expect(page).to have_selector '#popup_before_video', text: false
        expect(page).to have_selector '#popup_after_video', text: false
        click_button '新規投稿'
        expect(page).to have_current_path videos_path, ignore_query: true
        expect(page).to have_text '動画を投稿しました'
      end
    end
  end

  describe '正常(動画投稿者)' do
    describe '動画一覧ページ' do
      before(:each) do
        sign_in user
        visit videos_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'サンプルビデオ', href: video_path(video_sample)
      end
    end

    describe '動画詳細' do
      before(:each) do
        visit video_path(video_sample)
      end

      it 'レイアウト' do
        expect(page).to have_text 'サンプルビデオ'
      end
    end

    describe '動画投稿画面' do
      before(:each) do
        sign_in user_owner
        visit new_video_path
      end

      it 'レイアウト' do
        expect(page).to have_button '新規投稿'
        expect(page).to have_field 'title'
        expect(page).to have_field 'post'
        expect(page).to have_selector '#range'
        expect(page).to have_selector '#comment_public'
        expect(page).to have_selector '#popup_before_video'
        expect(page).to have_selector '#popup_after_video'
      end

      it '新規作成で動画が作成される' do
        # fill_inの値は、ビューのフォームのfieldのid
        fill_in 'title', with: 'サンプルビデオ２'
        # spec/fixtures/filesフォルダに入れたビデオをアップロード
        attach_file 'video[video]', File.join(Rails.root, 'spec/fixtures/files/画面収録 2022-08-30 3.57.50.mov')
        fill_in 'open_period', with: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00'
        expect(page).to have_selector '#range', text: false
        expect(page).to have_selector '#comment_public', text: false
        expect(page).to have_selector '#popup_before_video', text: false
        expect(page).to have_selector '#popup_after_video', text: false
        click_button '新規投稿'
        expect(page).to have_current_path videos_path, ignore_query: true
        expect(page).to have_text '動画を投稿しました'
      end
    end
  end

  describe '異常' do
    describe '動画投稿画面' do
      before(:each) do
        sign_in user
        visit new_video_path
      end

      it 'タイトル空白' do
        fill_in 'title', with: ''
        fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov')
        click_button '新規投稿'
        expect(page).to have_text 'タイトルを入力してください'
      end

      it 'タイトル重複' do
        fill_in 'title', with: 'サンプルビデオ'
        fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov')
        click_button '新規投稿'
        expect(page).to have_text 'タイトルはすでに存在します'
      end

      it 'ビデオ空白' do
        fill_in 'title', with: 'サンプルビデオ2'
        click_button '新規投稿'
        expect(page).to have_text 'ビデオを入力してください'
      end
    end

    describe '動画一覧画面' do
      before(:each) do
        sign_in user
        visit videos_path
      end

      it '他の組織の動画は見れない' do
        expect(page).not_to have_text 'ITビデオ'
      end
    end
  end
end
