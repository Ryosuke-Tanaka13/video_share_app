require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  let(:viewer) { create(:viewer) }

  context 'サイドバーの項目/遷移確認' do
    before(:each) do
      viewer
    end

    describe 'システム管理者' do
      before(:each) do
        login(viewer)
        current_viewer(viewer)
        visit viewers_path(viewer)
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
end
