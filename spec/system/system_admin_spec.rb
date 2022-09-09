require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  let(:system_admin) { create(:system_admin) }

  context 'サイドバーの項目/遷移確認' do
    before(:each) do
      system_admin
    end

    describe 'システム管理者' do
      before(:each) do
        login(system_admin)
        current_system_admin(system_admin)
        visit system_admin_path(system_admin)
      end

      it 'レイアウト' do
        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'

        visit users_path

        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'

        viewers_path

        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_system_admin_path(system_admin), ignore_query: true
      end
    end
  end
end
