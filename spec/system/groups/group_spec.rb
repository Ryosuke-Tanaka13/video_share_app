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
      login(user_owner)
      current_user(user_owner)
      visit groups_path
    end

    it '正しい情報を入力すればグループ新規登録ができて一覧画面に移動する' do
      # 一覧ページに移動する
      # visit groups_path
      # 一覧ページに新規入力ページへ遷移するボタンがあることを確認する
      expect(page).to have_content('視聴グループ　新規作成画面へ')
      # 新規登録ページへ移動する
      visit new_group_path

      # グループ情報を入力する
      fill_in 'group[name]', with: 'New Group Name'
      # 登録ボタンを押すとグループモデルのカウントが1つ上がることを確認する
      expect {
        find('input[name="commit"]').click
      }.to change(Group, :count).by(1)
      # 一覧ページへ遷移したことを確認する
      expect(page).to have_current_path groups_path, ignore_query: true
    end

    it '誤った情報ではグループ新規登録ができずに新規登録ページへ戻ってくる' do
      # 一覧ページに移動する
      # visit groups_path
      # 一覧ページに新規登録ページへ遷移するボタンがあることを確認する
      expect(page).to have_content('視聴グループ　新規作成画面へ')
      # 新規登録ページへ移動する
      visit new_group_path

      # グループ情報を入力する
      fill_in 'group[name]', with: ''
      # 登録ボタンを押してもグループモデルのカウントは上がらないことを確認する
      expect {
        find('input[name="commit"]').click
      }.to change(Group, :count).by(0)
      # 新規登録ページへ戻されることを確認する
      expect(page).to have_current_path('/groups')
    end

    describe 'グループの編集' do
      let(:group) { create(:group, name: 'New Group Name') }
  
      before(:each) do
        login(user_owner)
        group
        visit groups_path
      end
  
      it '正しい情報を入力すればグループの編集ができて一覧画面に移動する' do
        expect(page).to have_content('New Group Name')
        # 編集ページへ移動する
        find_link('編集', href: edit_group_path(group.uuid)).click
        expect(page).to have_current_path(edit_group_path(group.uuid))
  
        # グループ名を編集する
        fill_in 'group[name]', with: 'Edit Group Name'
        find('input[name="commit"]').click
  
        # 一覧ページへ遷移したことを確認し、新しいグループ名が表示されていることを確認する
        expect(page).to have_current_path groups_path, ignore_query: true
        expect(page).to have_content('Edit Group Name')
      end
  
      it 'グループ名を空で更新しようとするとエラーメッセージが表示される' do
        expect(page).to have_content('New Group Name')
        # 編集ページへ移動する
        find_link('編集', href: edit_group_path(group.uuid)).click
        expect(page).to have_current_path(edit_group_path(group.uuid))
  
        # グループ名を空にして更新する
        fill_in 'group[name]', with: ''
        find('input[name="commit"]').click
  
        # 編集ページに留まり、エラーメッセージが表示されることを確認する
        expect(page).to have_current_path(group_path(group.uuid))
        expect(page).to have_content('エラー')
      end
    end
  end
end
