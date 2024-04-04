require 'rails_helper'

RSpec.describe 'グループ新規登録', type: :system do
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }

  describe 'グループの新規登録' do
    before(:each) do
      sign_in(user_owner)
      visit groups_path
    end

    it '正しい情報を入力すればグループ新規登録ができて一覧画面に移動する' do
      expect(page).to have_content('視聴グループ　新規作成画面へ')
      visit new_group_path
      fill_in 'group[name]', with: 'Group Name'
      expect { find('input[name="commit"]').click }.to change(Group, :count).by(1)
      expect(page).to have_current_path groups_path, ignore_query: true
    end

    it '誤った情報ではグループ新規登録ができずに新規登録ページへ戻ってくる' do
      expect(page).to have_content('視聴グループ　新規作成画面へ')
      visit new_group_path
      fill_in 'group[name]', with: ''
      expect { find('input[name="commit"]').click }.to change(Group, :count).by(0)
      expect(page).to have_current_path('/groups')
    end
  end

  describe 'グループの編集' do
    before(:each) do
      sign_in(user_owner)
      # 新規登録ページに遷移
      visit new_group_path
      fill_in 'group[name]', with: 'New Group Name'
      find('input[name="commit"]').click
      visit groups_path
    end

    it '正しい情報を入力すればグループの編集ができて一覧画面に移動する' do
      expect(page).to have_content('New Group Name')
      find_link('編集', href: edit_group_path(Group.find_by(name: 'New Group Name').uuid)).click
      fill_in 'group[name]', with: 'Edited Group Name'
      find('input[name="commit"]').click
      expect(page).to have_current_path groups_path, ignore_query: true
      expect(page).to have_content('Edited Group Name')
    end

    it 'グループ名を空で更新しようとするとエラーメッセージが表示される' do
      group = Group.find_by(name: 'New Group Name')
      visit edit_group_path(group.uuid)
      fill_in 'group[name]', with: ''
      find('input[name="commit"]').click
      expect(page).to have_current_path(group_path(group.uuid))
      expect(page).to have_content('視聴グループ名を入力してください')
    end
  end

  # グループの削除テスト
  describe 'グループの削除' do
    let!(:group) { create(:group, organization_id: user_staff.organization_id) }

    context '投稿者でログイン' do
      before(:each) do
        sign_in(user_staff)
        visit groups_path
      end

      it '視聴グループの削除に失敗する' do
        expect(page).to have_content(group.name)
        find_link('削除', href: group_path(group.uuid)).click
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content('権限がありません')
        expect(page).to have_current_path(groups_path, ignore_query: true)
        expect(Group.count).to eq 1
      end
    end

    context 'オーナーでログイン' do
      let!(:group) { create(:group, organization_id: user_owner.organization_id) }

      before(:each) do
        sign_in(user_owner)
        visit groups_path
      end

      it '視聴グループの削除に成功する' do
        expect(page).to have_content(group.name)
        find_link('削除', href: group_path(group.uuid)).click
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content('グループを削除しました')
        expect(page).to have_current_path(groups_path, ignore_query: true)
        expect(Group.count).to eq 0
      end
    end
  end
end
