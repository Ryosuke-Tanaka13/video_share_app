require 'rails_helper'

RSpec.describe 'OrganizationUnsubscribe', type: :request do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }
  let(:user1) { create(:user1, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user) { create(:another_user, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_owner
    user
    user1
    another_organization
    another_user_owner
    another_user
    system_admin
    viewer
  end

  describe '組織退会' do
    describe '正常～異常' do
      describe '所属オーナー操作' do
        before(:each) do
          current_user(user_owner)
        end

        it '退会した後ログインできない' do
          expect {
            patch organizations_unsubscribe_path(organization)
          }.to change { Organization.find(organization.id).is_valid }.from(organization.is_valid).to(false)

          get new_user_session_path
          expect(response).to have_http_status(:success)
          post user_session_path, params: { user: { email: user_owner.email, password: user_owner.password } }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to 'http://www.example.com/users/sign_in'
        end
      end
    end

    describe '異常' do
      describe 'システム管理者操作' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '退会できない' do
          expect {
            patch organizations_unsubscribe_path(organization)
          }.not_to change { Organization.find(organization.id).is_valid }
        end
      end

      describe '同組織のスタッフ操作' do
        before(:each) do
          current_user(user)
        end

        it '退会できない' do
          expect {
            patch organizations_unsubscribe_path(organization)
          }.not_to change { Organization.find(organization.id).is_valid }
        end
      end

      describe '他組織のオーナー操作' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '退会できない' do
          expect {
            patch organizations_unsubscribe_path(organization)
          }.not_to change { Organization.find(organization.id).is_valid }
        end
      end

      describe '他組織のスタッフ操作' do
        before(:each) do
          current_user(another_user)
        end

        it '退会できない' do
          expect {
            patch organizations_unsubscribe_path(organization)
          }.not_to change { Organization.find(organization.id).is_valid }
        end
      end

      describe '視聴者操作' do
        before(:each) do
          current_viewer(viewer)
        end

        it '退会できない' do
          expect {
            patch organizations_unsubscribe_path(organization)
          }.not_to change { Organization.find(organization.id).is_valid }
        end
      end

      describe 'ログインなし操作' do
        it '退会できない' do
          expect {
            patch organizations_unsubscribe_path(organization)
          }.not_to change { Organization.find(organization.id).is_valid }
        end
      end
    end
  end
end
