require 'rails_helper'

RSpec.describe 'グループ新規登録', type: :system do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization: organization, confirmed_at: Time.now) } 
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
  
  

  describe 'グループの編集' do
    before(:each) do
      organization = Organization.create(name: 'Test Organization') # 既存のOrganizationを作成
      @group = Group.create(name: 'Old Group Name', organization: organization) # 既存のグループを作成
      @test_user_owner = create(:test_user_owner, confirmed_at: Time.now) # test_user_ownerを作成
      login(@test_user_owner)
      current_user(@test_user_owner)
      visit edit_group_path(@group) # 編集ページに移動
    end

    it 'グループが正しく作成されている' do
      expect(@group).to be_present
      expect(@group.organization_id).to eq(@test_user_owner.organization_id)
    end
  end
end
