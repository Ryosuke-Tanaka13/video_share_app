require 'rails_helper'

RSpec.describe 'グループ新規登録', type: :system do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }
  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }
  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer1) { create(:organization_viewer1) }
  let(:organization_viewer2) { create(:organization_viewer2) }
  let(:organization_viewer3) { create(:organization_viewer3) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    organization_viewer
    organization_viewer1
    organization_viewer2
    organization_viewer3
  end

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

    describe 'グループの編集' do
      before(:each) do
        sign_in(user_owner)
        # 新規登録ページに遷移
        visit new_group_path
        # グループ名を記入する
        fill_in 'group[name]', with: 'New Group Name'
        # 新規登録ボタンをクリック
        find('input[name="commit"]').click
        # 一覧画面に遷移
        visit groups_path
      end
    
      it '正しい情報を入力すればグループの編集ができて一覧画面に移動する' do
        expect(page).to have_content('New Group Name')
    
        # 編集ページへの遷移
        find_link('編集', href: edit_group_path(Group.find_by(name: 'New Group Name').uuid)).click
    
        # 編集内容を入力
        fill_in 'group[name]', with: 'Edited Group Name'
    
        # 編集を保存
        find('input[name="commit"]').click
    
        # 一覧ページに戻り、編集結果を確認
        expect(page).to have_current_path groups_path, ignore_query: true
        expect(page).to have_content('Edited Group Name')
      end
    
      it 'グループ名を空で更新しようとするとエラーメッセージが表示される' do
        find_link('編集', href: edit_group_path(Group.find_by(name: 'New Group Name').uuid)).click
    
        fill_in 'group[name]', with: ''
        find('input[name="commit"]').click
    
        expect(page).to have_content('視聴グループ名を入力してください')
        expect(page).to have_current_path(edit_group_path(Group.find_by(name: 'New Group Name').uuid))
      end
    end
  end
end
