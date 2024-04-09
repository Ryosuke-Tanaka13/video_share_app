require 'rails_helper'

RSpec.describe 'グループ新規登録', type: :system do
  let(:organization) { create(:organization) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer) }
  let(:viewer1) { create(:viewer1) }
  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer2) { create(:organization_viewer2) }
  before(:each) do
    organization
    user_staff
    user_owner
    viewer
    viewer1
    organization_viewer
    organization_viewer2  
  end

  describe 'グループの新規登録' do
    let(:current_user) { user_owner }
  
    before(:each) do
      sign_in(current_user)
      visit groups_path
    end
  
    describe '確認' do
      it '正しい情報を入力すればグループ新規登録ができて一覧画面に移動する' do
        expect(page).to have_content('視聴グループ　新規作成画面へ')
        visit new_group_path
        fill_in 'group[name]', with: 'Group Name'
        # フォームの選択肢にorganization_viewer.viewer.name, organization_viewer2.viewer.nameが表示されていることを確認する。
        expect(page).to have_select('viewer-select', options: [organization_viewer.viewer.name, organization_viewer2.viewer.name])
        # 確認後、organization_viewer.viewer.nameを選択する。
        select organization_viewer.viewer.name, from: 'viewer-select'
        expect { find('input[name="commit"]').click }.to change(Group, :count).by(1)
        expect(page).to have_current_path groups_path, ignore_query: true
      end
    end
  end
end
