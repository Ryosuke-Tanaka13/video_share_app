require 'rails_helper'

RSpec.describe 'グループ新規登録', type: :system do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer) }
  let(:viewer1) { create(:viewer1) }
  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer2) { create(:organization_viewer2) }

  before(:each) do
    organization
    system_admin
    user_staff
    user_owner
    viewer
    viewer1
    organization_viewer
    organization_viewer2
  end

  describe 'ユーザーがグループを新規登録する' do
    let(:current_user) { user_owner }

    before(:each) do
      sign_in(current_user)
      visit groups_path
    end

    describe '視聴グループの新規登録' do
      it '視聴グループが正常に作成される' do
        expect(page).to have_content('視聴グループ　新規作成画面へ')
        visit new_group_path
        fill_in 'group[name]', with: 'Group Name'
        # フォームの選択肢にorganization_viewer.viewer.name, organization_viewer2.viewer.nameが表示されていることを確認する。
        expect(page).to have_select('viewer-select', options: [organization_viewer.viewer.name, organization_viewer2.viewer.name])
        select organization_viewer.viewer.name, from: 'viewer-select'
        expect { find('input[name="commit"]').click }.to change(Group, :count).by(1)
        expect(page).to have_current_path groups_path, ignore_query: true
      end

      it '視聴グループ名が空の場合、エラーメッセージが表示される' do
        visit new_group_path
        fill_in 'group[name]', with: ''
        find('input[name="commit"]').click
        expect(page).to have_current_path groups_path
        expect(page).to have_content('視聴グループ名を入力してください')
      end
    end
  end

  describe '視聴グループの編集' do
    context 'オーナーでログイン' do
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
        expect(page).to have_content('編集')
        group = Group.find_by(name: 'New Group Name')
        visit edit_group_path(group.uuid)
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
        expect(page).to have_current_path(edit_group_path(group.uuid, organization_id: group.organization_id))
        expect(page).to have_content('視聴グループ名を入力してください')
      end
    end

    context '管理者でログイン' do
      let!(:group) { create(:group) }

      before(:each) do
        sign_in(system_admin)
      end

      it '正しい情報を入力すればグループの編集ができて一覧画面に移動する' do
        visit edit_group_path(group.uuid)
        fill_in 'group[name]', with: 'Edited Group Name'
        find('input[name="commit"]').click
        expect(page).to have_current_path groups_path, ignore_query: true
        expect(page).to have_content('Edited Group Name')
      end

      it 'グループ名を空で更新しようとするとエラーメッセージが表示される' do
        visit edit_group_path(group.uuid)
        fill_in 'group[name]', with: ''
        find('input[name="commit"]').click
        expect(page).to have_current_path(edit_group_path(group.uuid, organization_id: group.organization_id))
        expect(page).to have_content('視聴グループ名を入力してください')
      end
    end
  end

  # グループの削除テスト
  describe 'グループの削除' do
    let!(:group) { create(:group, organization_id: user_staff.organization_id) }

    describe '投稿者でログイン' do
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

    describe 'オーナーでログイン' do
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
