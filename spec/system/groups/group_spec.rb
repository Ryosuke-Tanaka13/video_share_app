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
      it 'current_user.organization.organization_viewers.viewer.name を出力する' do
        current_user.organization.organization_viewers.each do |organization_viewer|
          puts organization_viewer.viewer.name
        end
      end
    end
  end
end
