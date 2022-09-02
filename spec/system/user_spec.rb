require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:user) { create(:user, organization_id: organization.id) }

  context 'サイドバーの項目/遷移確認' do
    before(:each) do
      organization
      user_owner
      user
    end

    describe 'オーナ' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit users_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'

        visit viewers_path

        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it '動画一覧への遷移' do
        click_link '動画フォルダ一覧'
        expect(page).to have_current_path folders_path, ignore_query: true
      end

      it '投稿者一覧への遷移' do
        click_link '投稿者一覧'
        expect(page).to have_current_path users_path, ignore_query: true
      end

      it '視聴者一覧への遷移' do
        click_link '視聴者一覧'
        expect(page).to have_current_path viewers_path, ignore_query: true
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_user_path(user_owner), ignore_query: true
      end
    end

    describe '動画投稿者' do
      before(:each) do
        login(user)
        current_user(user)
        visit users_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画一覧'
        expect(page).not_to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it '視聴者一覧への遷移' do
        click_link '視聴者一覧'
        expect(page).to have_current_path viewers_path, ignore_query: true
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_user_path(user), ignore_query: true
      end
    end
  end
end
