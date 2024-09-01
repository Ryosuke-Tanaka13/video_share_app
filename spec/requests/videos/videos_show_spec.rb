require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let!(:user_staff) { create(:user_staff, organization: organization, confirmed_at: Time.now) }
  let(:group) { create(:group, organization: organization) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }
  
  # 視聴グループで viewer と group を関連づける
  let!(:viewer_group) { create(:viewer_group, viewer: viewer, group: group) }
  let!(:group_video) {create(:group_video, group: group, video: limited_video)}
  let!(:organization_viewer) { create(:organization_viewer, viewer: viewer, organization: organization) }
  let!(:organization_viewer2) { create(:organization_viewer2, viewer: viewer1, organization: organization) }
  let!(:public_video) { create(:public_video) } # 一般公開の動画
  let!(:limited_video) { create(:limited_video) } # 限定公開の動画

  describe 'GET /videos' do
    context '視聴者でログイン' do
      it '動画一覧で、限定公開のビデオと一般公開のビデオが表示される' do
        sign_in viewer
        get videos_path(organization_id: organization.id)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(public_video.title, limited_video.title)
      end
    end

    context '視聴者１でログイン' do
      it '動画一覧で、一般公開のビデオのみ表示される' do
        sign_in viewer1
        get videos_path(organization_id: organization.id)
        expect(response.body).to include(public_video.title)
        expect(response.body).not_to include(limited_video.title)
      end
    end

    context '投稿者でログイン' do
      it '動画一覧で、全てのビデオが表示される' do
        sign_in user_staff
        get videos_path(organization_id: organization.id)
        expect(response.body).to include(public_video.title, limited_video.title)
      end
    end

    context 'システム管理者でログイン' do
      it '動画一覧で、全てのビデオが表示される' do
        sign_in system_admin
        get videos_path(organization_id: organization.id)
        expect(response.body).to include(public_video.title, limited_video.title)
      end
    end
  end  
end
