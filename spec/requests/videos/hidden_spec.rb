require 'rails_helper'

RSpec.describe 'UserUnsubscribe', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id) }
  # orgにのみ属す
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id, confirmed_at: Time.now) }

  # orgとviewerの紐付け
  let(:organization_viewer) { create(:organization_viewer) }

  before(:each) do
    system_admin
    organization
    another_organization
    user_owner
    another_user_owner
    user_staff
    viewer
    organization_viewer
  end

  describe '動画論理削除' do
    context '正常～異常' do
      context 'システム管理者操作' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '論理削除できる' do
          expect {
            patch videos_withdraw_path(video_test)
          }.to change { Video.find(video_test.id).is_valid }.from(video_test.is_valid).to(false)
        end

        it '論理削除した後もvideos#showにアクセスできる' do
          expect {
            patch videos_withdraw_path(video_test)
          }.to change { Video.find(video_test.id).is_valid }.from(video_test.is_valid).to(false)
          get video_path(video_test)
          expect(response).to have_http_status(:success)
        end
      end

      context 'オーナー操作' do
        before(:each) do
          current_user(user_owner)
        end

        it '論理削除できる' do
          expect {
            patch videos_withdraw_path(video_test)
          }.to change { Video.find(video_test.id).is_valid }.from(video_test.is_valid).to(false)
        end

        it '論理削除した後videos#showにアクセスできない' do
          expect {
            patch videos_withdraw_path(video_test)
          }.to change { Video.find(video_test.id).is_valid }.from(video_test.is_valid).to(false)

          get video_path(video_test)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to root_url
        end
      end
    end

    context '異常' do
      context '動画投稿者' do
        before(:each) do
          current_user(user_staff)
        end

        it '論理削除できない' do
          expect {
            patch videos_withdraw_path(video_test)
          }.not_to change { Video.find(video_test.id).is_valid }
        end
      end

      context '別組織のオーナー操作' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '論理削除できない' do
          expect {
            patch videos_withdraw_path(video_test)
          }.not_to change { Video.find(video_test.id).is_valid }
        end
      end

      context '視聴者操作' do
        before(:each) do
          current_viewer(viewer)
        end

        it '論理削除できない' do
          expect {
            patch videos_withdraw_path(video_test)
          }.not_to change { Video.find(video_test.id).is_valid }
        end
      end

      context '非ログイン操作' do
        it '論理削除できない' do
          expect {
            patch videos_withdraw_path(video_test)
          }.not_to change { Video.find(video_test.id).is_valid }
        end
      end
    end
  end
end
