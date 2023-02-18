require 'rails_helper'

RSpec.describe 'ViewerSessions', type: :system do
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:deactivated_viewer) { create(:deactivated_viewer, confirmed_at: Time.now) }
  let(:same_email_viewer) { create(:same_email_viewer, confirmed_at: Time.now) }

  before(:each) do
    viewer
    deactivated_viewer
    same_email_viewer
  end

  context '正常' do
    it 'ログインできる' do
      visit new_viewer_session_path
      fill_in 'viewer[email]', with: viewer.email
      fill_in 'viewer[password]', with: viewer.password
      click_button 'ログイン'
      expect(page).to have_content 'ログアウト'
    end

    it '論理削除と同じメールを使いまわせる' do
      visit new_viewer_session_path
      fill_in 'viewer[email]', with: same_email_viewer.email
      fill_in 'viewer[password]', with: same_email_viewer.password
      click_button 'ログイン'
      expect(page).to have_content 'ログアウト'
    end
  end

  context '異常' do
    it '論理削除アカウントはログインできない' do
      visit new_viewer_session_path
      fill_in 'viewer[email]', with: deactivated_viewer.email
      fill_in 'viewer[password]', with: deactivated_viewer.password
      click_button 'ログイン'
      expect(page).to have_content 'Eメールまたはパスワードが違います。'
    end
  end
end
