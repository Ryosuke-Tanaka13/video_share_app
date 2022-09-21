require 'rails_helper'

RSpec.describe 'LoginlessViewerSystem', type: :system do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }
  let(:loginless_viewer) { create(:loginless_viewer) }
  let(:loginless_viewer1) { create(:loginless_viewer1) }

  let(:another_organization) { create(:another_organization) }
  let(:another_loginless_viewer) { create(:another_loginless_viewer) }

  let(:organization_loginless_viewer) { create(:organization_loginless_viewer) }
  let(:organization_loginless_viewer1) { create(:organization_loginless_viewer1) }
  let(:organization_loginless_viewer2) { create(:organization_loginless_viewer2) }
  let(:organization_loginless_viewer3) { create(:organization_loginless_viewer3) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    loginless_viewer
    loginless_viewer1
    another_organization
    another_loginless_viewer
    organization_loginless_viewer
    organization_loginless_viewer1
    organization_loginless_viewer2
    organization_loginless_viewer3
  end

  context 'オーナー操作' do
    describe '正常' do
      context 'ログインなし視聴者一覧' do
        before(:each) do
          login(user_owner)
          current_user(user_owner)
          visit loginless_viewers_path(organization_id: organization.id)
        end

        it 'レイアウト' do
          expect(page).to have_link loginless_viewer.name, href: loginless_viewer_path(loginless_viewer)
          expect(page).to have_link loginless_viewer1.name, href: loginless_viewer_path(loginless_viewer1)
          expect(page).to have_link '削除', href: loginless_viewers_unsubscribe_path(loginless_viewer)
          expect(page).to have_link '削除', href: loginless_viewers_unsubscribe_path(loginless_viewer1)
        end

        it 'ログインなし視聴者詳細への遷移' do
          click_link loginless_viewer.name
          expect(page).to have_current_path loginless_viewer_path(loginless_viewer), ignore_query: true
        end

        it 'ログインなし視聴者1詳細への遷移' do
          click_link loginless_viewer1.name
          expect(page).to have_current_path loginless_viewer_path(loginless_viewer1), ignore_query: true
        end

        it 'ログインなし論理削除' do
          find(:xpath, '//*[@id="loginless_viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[2]/td[3]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'ログインなしの視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'ログインなしのユーザー情報を削除しました'
          }.to change { LoginlessViewer.find(loginless_viewer.id).is_valid }.from(loginless_viewer.is_valid).to(false)
        end

        it 'ログインなし論理削除キャンセル' do
          find(:xpath, '//*[@id="loginless_viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[2]/td[3]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'ログインなしの視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(LoginlessViewer, :count)
        end

        it 'ログインなし1削除' do
          find(:xpath, '//*[@id="loginless_viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[3]/td[3]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'ログインなし1の視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'ログインなし1のユーザー情報を削除しました'
          }.to change { LoginlessViewer.find(loginless_viewer1.id).is_valid }.from(loginless_viewer1.is_valid).to(false)
        end

        it 'ログインなし1削除キャンセル' do
          find(:xpath, '//*[@id="loginless_viewers-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[3]/td[3]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'ログインなし1の視聴者情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(LoginlessViewer, :count)
        end
      end

      context 'ログインなし視聴者詳細' do
        before(:each) do
          login(user_owner)
          current_user(user_owner)
          visit loginless_viewer_path(loginless_viewer)
        end

        it 'レイアウト' do
          expect(page).to have_text loginless_viewer.email
          expect(page).to have_text loginless_viewer.name
          expect(page).to have_text organization.name
        end

        it '所属組織への遷移' do
          click_link 'セレブエンジニア'
          expect(page).to have_current_path organization_path(organization), ignore_query: true
        end
      end
    end
  end
end
