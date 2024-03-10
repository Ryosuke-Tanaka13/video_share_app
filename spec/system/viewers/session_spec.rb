require 'rails_helper'

RSpec.xdescribe 'ViewerSessions', type: :system do
  context 'ログインできることを確認' do
    let!(:viewer) { FactoryBot.create(:viewer, password: 'password', confirmed_at: Time.now) }

    it 'ログインできることを確認' do
      visit new_viewer_session_path
      fill_in 'viewer[email]', with: viewer.email
      fill_in 'viewer[password]', with: viewer.password
      click_button 'ログイン'
      expect(page).to have_content 'ログアウト'
    end
  end
end
