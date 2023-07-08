require 'rails_helper'

RSpec.xdescribe 'OrganizationUnsubscribeSystem', type: :system do
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

  context '組織退会' do
    xdescribe '正常' do
      context '本人操作' do
        before(:each) do
          login(user_owner)
          current_user(user_owner)
          visit organizations_unsubscribe_path(organization)
        end

        it 'レイアウト' do
          expect(page).to have_link '退会しない', href: organization_path(organization)
          expect(page).to have_link '退会する', href: organizations_unsubscribe_path(organization)
        end

        it '詳細へ遷移' do
          click_link '退会しない'
          expect(page).to have_current_path organization_path(organization), ignore_query: true
        end

        it '退会する' do
          expect {
            click_link '退会する'
            expect(page).to have_content '退会処理が完了しました。'
          }.to change { Organization.find(organization.id).is_valid }.from(organization.is_valid).to(false)
        end
      end
    end
  end
end
