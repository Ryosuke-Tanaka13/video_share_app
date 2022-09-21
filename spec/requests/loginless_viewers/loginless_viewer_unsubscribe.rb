require 'rails_helper'

RSpec.describe 'LoginlessViewerUnsubscribe', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }
  let(:loginless_viewer) { create(:loginless_viewer) }
  let(:loginless_viewer1) { create(:loginless_viewer1) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }
  let(:another_loginless_viewer) { create(:another_loginless_viewer) }

  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer1) { create(:organization_viewer1) }

  let(:organization_loginless_viewer) { create(:organization_loginless_viewer) }
  let(:organization_loginless_viewer1) { create(:organization_loginless_viewer1) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    loginless_viewer
    loginless_viewer1
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    another_loginless_viewer
    organization_viewer
    organization_viewer1
    organization_loginless_viewer
    organization_loginless_viewer1
  end

  context '視聴者退会' do
    describe '正常' do
      context '同組織オーナー' do
        before(:each) do
          current_user(user_owner)
        end

        it '退会できる' do
          expect {
            patch loginless_viewers_unsubscribe_path(loginless_viewer)
          }.to change { LoginlessViewer.find(loginless_viewer.id).is_valid }.from(loginless_viewer.is_valid).to(false)
        end
      end
    end

    describe '異常' do
      context 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '退会できない' do
          expect {
            patch loginless_viewers_unsubscribe_path(loginless_viewer)
          }.not_to change { LoginlessViewer.find(loginless_viewer.id).is_valid }
        end
      end

      context '他組織オーナー' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '退会できない' do
          expect {
            patch loginless_viewers_unsubscribe_path(loginless_viewer)
          }.not_to change { LoginlessViewer.find(loginless_viewer.id).is_valid }
        end
      end

      context '同組織スタッフ' do
        before(:each) do
          current_user(user_staff)
        end

        it '退会できない' do
          expect {
            patch loginless_viewers_unsubscribe_path(loginless_viewer)
          }.not_to change { LoginlessViewer.find(loginless_viewer.id).is_valid }
        end
      end

      context '他組織スタッフ' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '退会できない' do
          expect {
            patch loginless_viewers_unsubscribe_path(loginless_viewer)
          }.not_to change { LoginlessViewer.find(loginless_viewer.id).is_valid }
        end
      end

      context '他視聴者' do
        before(:each) do
          current_viewer(viewer1)
        end

        it '退会できない' do
          expect {
            patch loginless_viewers_unsubscribe_path(loginless_viewer)
          }.not_to change { LoginlessViewer.find(loginless_viewer.id).is_valid }
        end
      end

      context 'ログインなし' do
        it '退会できない' do
          expect {
            patch loginless_viewers_unsubscribe_path(loginless_viewer)
          }.not_to change { LoginlessViewer.find(loginless_viewer.id).is_valid }
        end
      end
    end
  end
end
