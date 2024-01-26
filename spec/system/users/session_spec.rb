require 'rails_helper'

rspec.xdescribe 'UserSessions', type: :system do
  context 'ログインできることを確認' do
    let(:organization) { create(:organization) }
    let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }

    before(:each) do
      organization
      user_staff
    end

    it 'ログインできることを確認' do
      visit new_user_session_path
      fill_in 'user[email]', with: user_staff.email
      fill_in 'user[password]', with: user_staff.password
      click_button 'ログイン'
      expect(page).to have_content 'ログアウト'
    end
  end
end
