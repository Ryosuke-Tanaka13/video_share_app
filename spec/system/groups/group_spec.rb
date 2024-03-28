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

  describe 'グループの新規登録と編集' do
    before(:each) do
      login(user_owner)
      current_user(user_owner)
      visit groups_path
    end
  
    it '正しい情報を入力すればグループ新規登録ができて、続いて編集ができる' do
      # 一覧ページに新規入力ページへ遷移するボタンを確認
      expect(page).to have_content('視聴グループ　新規作成画面へ')
      visit new_group_path
  
      # 新規登録
      fill_in 'group[name]', with: 'New Group Name'
      expect { find('input[name="commit"]').click }.to change(Group, :count).by(1)
      expect(page).to have_current_path groups_path, ignore_query: true
  
      # 新規登録されたグループが一覧に表示されていることを確認
      expect(page).to have_content('New Group Name')
  
      # 編集ページへ移動
      find_link('編集', href: edit_group_path(Group.last.uuid)).click
      expect(page).to have_current_path(edit_group_path(Group.last.uuid))
  
      # 編集
      fill_in 'group[name]', with: 'Edit Group Name'
      find('input[name="commit"]').click
  
      # 一覧ページに遷移して、編集されたグループ名が表示されることを確認
      expect(page).to have_current_path groups_path, ignore_query: true
      expect(page).to have_content('Edit Group Name')
    end
  end
end
