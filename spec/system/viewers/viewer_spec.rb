require 'rails_helper'

RSpec.describe 'ViewerSystem', type: :system do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_owner
    user
    system_admin
    viewer
    viewer1
  end

  context 'サイドバーの項目/遷移確認' do
    before(:each) do
      viewer
    end

    describe 'システム管理者' do
      before(:each) do
        login(viewer)
        current_viewer(viewer)
        visit viewer_path(viewer)
      end

      it 'レイアウト' do
        expect(page).to have_link '動画一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_viewer_path(viewer), ignore_query: true
      end
    end
  end

  context 'Viewer操作' do
    describe '正常' do
      describe '視聴者一覧ページ' do
        before(:each) do
          login(system_admin)
          current_system_admin(system_admin)
          visit viewers_path
        end

        it 'レイアウト' do
          expect(page).to have_link viewer.name, href: viewer_path(viewer)
          expect(page).to have_link viewer.name, href: viewer_path(viewer1)
          expect(page).to have_link '削除', href: viewer_path(viewer)
          expect(page).to have_link '削除', href: viewer_path(viewer1)
        end

        it 'viewer詳細への遷移' do
          click_link viewer.name
          expect(page).to have_current_path viewer_path(viewer), ignore_query: true
        end

        it 'viewer1詳細への遷移' do
          click_link viewer1.name
          expect(page).to have_current_path viewer_path(viewer1), ignore_query: true
        end

        it 'viewer削除' do
          find(:xpath, '//*[@id="viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[1]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'viewerの視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'viewerのユーザー情報を削除しました'
          }.to change(Viewer, :count).by(-1)
        end

        it 'viewer削除キャンセル' do
          find(:xpath, '//*[@id="viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[1]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'viewerの視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(Viewer, :count)
        end

        it 'viewer1削除' do
          find(:xpath, '//*[@id="viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[2]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'viewer1の視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'viewer1のユーザー情報を削除しました'
          }.to change(Viewer, :count).by(-1)
        end

        it 'viewer1削除キャンセル' do
          find(:xpath, '//*[@id="viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[2]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'viewer1の視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(Viewer, :count)
        end
      end

      describe '視聴者詳細' do
        before(:each) do
          login(viewer)
          current_viewer(viewer)
          visit viewer_path(viewer)
        end

        it 'レイアウト' do
          expect(page).to have_text viewer.email
          expect(page).to have_text viewer.name
          expect(page).to have_link '編集', href: edit_viewer_path(viewer)
          expect(page).to have_link '戻る', href: viewers_path
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_viewer_path(viewer), ignore_query: true
        end

        it '戻るへの遷移' do
          click_link '戻る'
          expect(page).to have_current_path viewers_path, ignore_query: true
        end
      end

      describe '視聴者編集' do
        before(:each) do
          login(viewer)
          current_viewer(viewer)
          visit edit_viewer_path(viewer)
        end

        it 'レイアウト' do
          expect(page).to have_field 'Name'
          expect(page).to have_field 'Eメール'
          expect(page).to have_button '更新'
          expect(page).to have_link '詳細画面へ'
          expect(page).to have_link '一覧画面へ'
        end

        it '更新で登録情報が更新される' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_current_path viewer_path(viewer), ignore_query: true
          expect(page).to have_text '更新しました'
        end
      end
    end

    describe '異常' do
      describe '視聴者編集' do
        before(:each) do
          login(viewer)
          current_viewer(viewer)
          visit edit_viewer_path(viewer)
        end

        it 'Name空白' do
          fill_in 'Name', with: ''
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_text 'Nameを入力してください'
        end

        it 'Name10文字以上' do
          fill_in 'Name', with: 'a' * 11
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_text 'Nameは10文字以内で入力してください'
        end

        it 'Eメール空白' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: ''
          click_button '更新'
          expect(page).to have_text 'Eメールを入力してください'
        end

        it 'Eメール重複' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'test1@example.com'
          click_button '更新'
          expect(page).to have_text 'Eメールはすでに存在します'
        end
      end
    end
  end
end
