require 'rails_helper'

RSpec.describe 'VideoStatuses', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }
  # orgにのみ属す
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  # another_orgのみに属す
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }
  # orgとanother_orgの両方に属す
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }

  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id, confirmed_at: Time.now) }
  let(:another_video) { create(:another_video, organization_id: another_user_owner.organization.id, user_id: another_user_owner.id) }

  # orgとviewerの紐付け
  let(:organization_viewer) { create(:organization_viewer) }
  # another_orgとanother_viewerの紐付け
  let(:organization_viewer1) { create(:organization_viewer1) }
  # orgとviewer1の紐付け
  let(:organization_viewer2) { create(:organization_viewer2) }

  let(:video_sample_status) { create(:video_sample_status, video_id: video_sample.id, viewer_id: viewer.id) }

  before(:each) do
    system_admin
    organization
    another_organization
    user_owner
    another_user_owner
    user_staff
    viewer
    another_viewer
    organization_viewer
    organization_viewer1
    video_sample
    video_test
    video_sample_status
  end

  describe 'GET #index' do
    describe '正常(動画投稿者)' do
      before(:each) do
        sign_in user_staff
        get video_statuses_path(video_sample)
      end

      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(オーナー)' do
      before(:each) do
        sign_in user_owner
        get video_statuses_path(video_sample)
      end

      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(システム管理者)' do
      before(:each) do
        sign_in system_admin
        get video_statuses_path(video_sample)
      end

      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '異常(別組織のuser)' do
      before(:each) do
        sign_in another_user_owner
        get video_statuses_path(video_sample)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to videos_url(organization_id: another_organization.id)
      end
    end

    describe '異常(視聴者)' do
      before(:each) do
        sign_in viewer
        get video_statuses_path(video_sample)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        redirect_to root_url
      end
    end

    describe '異常(非ログイン)' do
      before(:each) do
        get video_statuses_path(video_sample)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'PATCH #update' do
    describe '視聴者本人が現在のログインユーザ' do
      before(:each) do
        sign_in viewer
      end

      describe '正常' do
        it '視聴状況がアップデートされる' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {
                  latest_start_point: 6.0,
                  latest_end_point:   12.8548,
                  total_time:         12.97,
                  video_id:           video_sample.id,
                  viewer_id:          viewer.id
                }
              }
          }.to change {
                 VideoStatus.find(video_sample_status.id).latest_end_point
               }.from(video_sample_status.latest_end_point).to(12.8548) \
               && change {
                 VideoStatus.find(video_sample_status.id).watched_at
               }.from(video_sample_status.watched_at).to(Time.current) \
               && change {
                 VideoStatus.find(video_sample_status.id).watched_ratio
               }.from(video_sample_status.watched_ratio).to(100.0)
        end
      end

      describe '異常' do
        it 'すでに視聴した部分をもう一度視聴して再生を終了する場合(新しい部分を視聴しない場合は、視聴状況がアップデートされない' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {
                  latest_end_point: 5.9,
                  total_time:       12.97,
                  video_id:         video_sample.id,
                  viewer_id:        viewer.id
                }
              }
          }.not_to change { VideoStatus.find(video_sample_status.id).latest_end_point }
        end

        it 'すでに保存されている再生完了地点より後の地点から再生を開始する場合は、視聴状況がアップデートされない' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {
                  latest_start_point: 6.1,
                  latest_end_point:   12.8548,
                  total_time:         12.97,
                  video_id:           video_sample.id,
                  viewer_id:          viewer.id
                }
              }
          }.not_to change { VideoStatus.find(video_sample_status.id).latest_end_point }
        end
      end
    end

    describe '別組織の視聴者がログインユーザ' do
      before(:each) do
        sign_in another_viewer
      end

      describe '異常' do
        it '別組織の視聴者はアップデートできない' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {

                  latest_end_point: 12.8548,
                  total_time:       12.97,
                  video_id:         video_sample.id,
                  viewer_id:        viewer.id
                }
              }
          }.not_to change { VideoStatus.find(video_sample_status.id).latest_end_point }
        end
      end
    end

    describe 'システム管理者がログインユーザ' do
      before(:each) do
        sign_in system_admin
      end

      describe '異常' do
        it 'システム管理者はアップデートできない' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {

                  latest_end_point: 12.8548,
                  total_time:       12.97,
                  video_id:         video_sample.id,
                  viewer_id:        viewer.id
                }
              }
          }.not_to change { VideoStatus.find(video_sample_status.id).latest_end_point }
        end
      end
    end

    describe 'オーナーが現在のログインユーザ' do
      before(:each) do
        sign_in user_owner
      end

      describe '異常' do
        it 'オーナーはアップデートできない' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {
                  latest_end_point: 12.8548,
                  total_time:       12.97,
                  video_id:         video_sample.id,
                  viewer_id:        viewer.id
                }
              }
          }.not_to change { VideoStatus.find(video_sample_status.id).latest_end_point }
        end
      end
    end

    describe 'スタッフが現在のログインユーザ' do
      before(:each) do
        sign_in user_staff
      end

      describe '異常' do
        it 'スタッフはアップデートできない' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {
                  latest_end_point: 12.8548,
                  total_time:       12.97,
                  video_id:         video_sample.id,
                  viewer_id:        viewer.id
                }
              }
          }.not_to change { VideoStatus.find(video_sample_status.id).latest_end_point }
        end
      end
    end

    describe '非ログイン' do
      describe '異常' do
        it '非ログインはアップデートできない' do
          expect {
            patch video_status_path(video_sample_status),
              params: {
                video_status: {
                  latest_end_point: 12.8548,
                  total_time:       12.97,
                  video_id:         video_sample.id,
                  viewer_id:        viewer.id
                }
              }
          }.not_to change { VideoStatus.find(video_sample_status.id).latest_end_point }
        end
      end
    end

    describe 'DELETE #destroy' do
      describe 'システム管理者が現在のログインユーザー' do
        before(:each) do
          sign_in system_admin
        end

        describe '正常' do
          it '動画を削除する' do
            expect {
              delete(video_status_path(video_sample_status, video_id: video_sample.id))
            }.to change(VideoStatus, :count).by(-1)
          end

          it 'indexにリダイレクトされる' do
            expect(
              delete(video_status_path(video_sample_status, video_id: video_sample.id))
            ).to redirect_to video_statuses_path(video_sample)
          end
        end
      end

      describe 'オーナーが現在のログインユーザー' do
        before(:each) do
          sign_in user_owner
        end

        describe '異常' do
          it 'オーナーは削除できない' do
            expect {
              delete(video_status_path(video_sample_status, video_id: video_sample.id))
            }.not_to change(VideoStatus, :count)
          end
        end
      end

      describe '動画投稿者が現在のログインユーザ' do
        before(:each) do
          sign_in user_staff
        end

        describe '異常' do
          it '動画投稿者は削除できない' do
            expect {
              delete video_status_path(video_sample_status, video_id: video_sample.id)
            }.not_to change(VideoStatus, :count)
          end
        end
      end

      describe '視聴者が現在のログインユーザ' do
        before(:each) do
          sign_in viewer
        end

        describe '異常' do
          it '視聴者は削除できない' do
            expect {
              delete video_status_path(video_sample_status, video_id: video_sample.id)
            }.not_to change(VideoStatus, :count)
          end
        end
      end

      describe '非ログイン' do
        describe '異常' do
          it '非ログインでは削除できない' do
            expect {
              delete video_status_path(video_sample_status, video_id: video_sample.id)
            }.not_to change(VideoStatus, :count)
          end
        end
      end
    end
  end
end
