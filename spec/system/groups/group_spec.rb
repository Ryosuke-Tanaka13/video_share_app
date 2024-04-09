require 'rails_helper'

RSpec.describe 'グループ新規登録', type: :system do
  let(:organization) { create(:organization) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, organization: organization) }
  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer2) { create(:organization_viewer2) }
  before(:each) do
    organization
    user_owner
    user_staff
  end

  describe 'グループの新規登録' do
    before(:each) do
      sign_in(user_owner)
      visit groups_path
    end

    describe '確認' do
      it 'organization_viewer.viewer.name を出力する' do
        organization_viewer = create(:organization_viewer)
        puts organization_viewer.viewer.name
      end
    end
  end
end
