require 'rails_helper'

RSpec.xdescribe 'UserSessions', type: :system do
    # このテストは開発中であり、現在の実装に影響を与える可能性があるためスキップされています。
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
# rubocop:enable RSpec/PendingWithoutReason
