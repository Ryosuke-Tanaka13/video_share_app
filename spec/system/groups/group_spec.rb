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
      # 新規登録ページへ移動する
      visit new_group_path

      # グループ情報を入力する
      fill_in 'group[name]', with: 'New Group Name'
      # 入力した値が正しく反映されていることを確認する
      expect(page).to have_field('group[name]', with: 'New Group Name')

      # 登録ボタンを押す
      find('input[name="commit"]').click
      # ボタンを押した後、一覧ページへ遷移したことを確認する
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
  end

  describe 'グループの編集' do
    before(:each) do
      @group = Group.create(name: 'Old Group Name') # 既存のグループを作成
      login(user_owner)
      current_user(user_owner)
      visit edit_group_path(@group) # 編集ページに移動
    end
  
    it '正しい情報を入力すればグループ情報が更新されて一覧画面に移動する' do
      fill_in 'group[name]', with: 'New Group Name' # グループ情報を更新
      expect {
        find('input[name="commit"]').click
      }.to change { @group.reload.name }.from('Old Group Name').to('New Group Name') # データベースのグループが更新されていることを確認
      expect(page).to have_current_path groups_path, ignore_query: true # 一覧ページにリダイレクトされることを確認
    end
  
    it '誤った情報ではグループ情報が更新されずに編集ページへ戻ってくる' do
      fill_in 'group[name]', with: '' # グループ情報を更新
      expect {
        find('input[name="commit"]').click
      }.not_to change { @group.reload.name } # データベースのグループが更新されていないことを確認
      expect(page).to have_current_path edit_group_path(@group) # 編集ページにリダイレクトされることを確認
    end
  end

  describe 'グループの削除' do
    before(:each) do
      @group = Group.create(name: 'Test Group') # テスト用のグループを作成
    end

    context 'システム管理者またはオーナーとして' do
      before(:each) do
        login(user_owner) # オーナーとしてログイン
        current_user(user_owner)
        visit groups_path # グループ一覧ページに移動
      end

      it '削除リンクをクリックするとグループが削除される' do
        expect {
          find_link('削除', href: group_path(@group)).click
        }.to change(Group, :count).by(-1) # グループが1つ減ることを確認
        expect(page).to have_current_path groups_path, ignore_query: true # 一覧ページにリダイレクトされることを確認
        expect(page).not_to have_content @group.name # 削除したグループ名が表示されていないことを確認
      end
    end

    context '投稿者として' do
      before(:each) do
        login(user_staff) # 投稿者としてログイン
        current_user(user_staff)
        visit groups_path # グループ一覧ページに移動
      end

      it '削除リンクをクリックしてもグループが削除されない' do
        expect {
          find_link('削除', href: group_path(@group)).click
        }.not_to change(Group, :count) # グループが減らないことを確認
        expect(page).to have_content '権限がありません。' # 適切なエラーメッセージが表示されることを確認
      end
    end
  end
end
