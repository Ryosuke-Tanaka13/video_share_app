require 'rails_helper'

RSpec.xdescribe 'SystemAdminSessions', type: :system do
  context 'ログインできることを確認' do
    let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

    it 'ログインできることを確認' do
      visit new_system_admin_session_path
      fill_in 'system_admin[email]', with: system_admin.email
      fill_in 'system_admin[password]', with: system_admin.password
      click_button 'ログイン'
      expect(page).to have_content 'ログアウト'
    end
  end
end
