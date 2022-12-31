require 'rails_helper'

RSpec.describe 'VideoStatusHidden', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }

  # orgにのみ属す
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id, confirmed_at: Time.now) }

  # orgとviewerの紐付け
  let(:organization_viewer) { create(:organization_viewer) }

  let(:video_sample_status) { create(:video_sample_status, video_id: video_sample.id, viewer_id: viewer.id) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    video_sample
    another_organization
    another_user_owner
    organization_viewer
    video_sample_status
  end

  describe '動画論理削除' do
    context '正常～異常' do
      context 'システム管理者操作' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '論理削除できる' do
          expect {
            patch video_status_withdraw_path(video_sample_status, video_id: video_sample.id)
          }.to change { VideoStatus.find(video_sample_status.id).is_valid }.from(video_sample_status.is_valid).to(false)
        end
      end

      context 'オーナー操作' do
        before(:each) do
          current_user(user_owner)
        end

        it '論理削除できる' do
          expect {
            patch video_status_withdraw_path(video_sample_status, video_id: video_sample.id)
          }.to change { VideoStatus.find(video_sample_status.id).is_valid }.from(video_sample_status.is_valid).to(false)
        end
      end
    end

    # context '異常' do
    #   context '動画投稿者' do
    #     before(:each) do
    #       current_user(user_staff)
    #     end

    #     it '論理削除できない' do
    #       expect {
    #         patch video_status_withdraw_path(video_sample_status, video_id: video_sample.id)
    #       }.not_to change { Video.find(video_sample_status.id).is_valid }
    #     end
    #   end

    #   context '別組織オーナー操作' do
    #     before(:each) do
    #       current_user(another_user_owner)
    #     end

    #     it '論理削除できない' do
    #       expect {
    #         patch video_status_withdraw_path(video_sample_status, video_id: video_sample.id)
    #       }.not_to change { Video.find(video_sample_status.id).is_valid }
    #     end
    #   end

    #   context '視聴者操作' do
    #     before(:each) do
    #       current_viewer(viewer)
    #     end

    #     it '論理削除できない' do
    #       expect {
    #         patch video_status_withdraw_path(video_sample_status, video_id: video_sample.id)
    #       }.not_to change { Video.find(video_sample_status.id).is_valid }
    #     end
    #   end

    #   context '非ログイン操作' do
    #     it '論理削除できない' do
    #       expect {
    #         patch video_status_withdraw_path(video_sample_status, video_id: video_sample.id)
    #       }.not_to change { Video.find(video_sample_status.id).is_valid }
    #     end
    #   end
    # end
  end
end
