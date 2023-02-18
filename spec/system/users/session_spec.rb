require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  let(:organization) { create(:organization) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:deactivated_user) { create(:deactivated_user, confirmed_at: Time.now) }
  let(:same_email_user) { create(:same_email_user, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_staff
    deactivated_user
    same_email_user
  end

  context '正常' do
    it 'ログインできることを確認' do
      visit new_user_session_path
      fill_in 'user[email]', with: user_staff.email
      fill_in 'user[password]', with: user_staff.password
      click_button 'ログイン'
      expect(page).to have_content 'ログアウト'
    end

    it '論理削除と同じメールを使いまわせることを確認' do
      visit new_user_session_path
      fill_in 'user[email]', with: same_email_user.email
      fill_in 'user[password]', with: same_email_user.password
      click_button 'ログイン'
      expect(page).to have_content 'ログアウト'
    end
  end

  context '異常' do
    it '論理削除アカウントはログインできない' do
      visit new_user_session_path
      fill_in 'user[email]', with: deactivated_user.email
      fill_in 'user[password]', with: deactivated_user.password
      click_button 'ログイン'
      expect(page).to have_content 'Eメールまたはパスワードが違います。'
    end
  end
end
