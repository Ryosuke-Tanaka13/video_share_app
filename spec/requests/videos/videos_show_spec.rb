require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:organization) { create(:test_organization) }
  let(:user) { create(:test_user, confirmed_at: Time.now) }
  let(:group) { create(:group) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let!(:viewer_group) { create(:viewer_group, viewer: viewer, group: group) }
  let!(:organization_viewer) { create(:organization_viewer, viewer: viewer, organization: organization) } 
  let!(:video) { create(:test_video1, user: user, organization: organization, groups: [group], range: true) } # range: true は限定公開
  let(:other_viewer) { create(:another_viewer, confirmed_at: Time.now) }
  let!(:other_organization_viewer) { create(:organization_viewer2, viewer: other_viewer, organization: organization) } 
  let!(:public_video) { create(:test_video2, user: user, organization: organization, range: false) } # range: false は一般公開

  describe 'GET /videos' do
    context '視聴者がログインし、限定公開ビデオの閲覧権限がある場合' do
      it '限定公開ビデオが表示される' do
        # 視聴者としてログイン
        sign_in viewer
        get videos_path(organization_id: organization.id) 
        expect(response).to have_http_status(:ok)
        # レスポンスボディに限定公開ビデオのタイトルが含まれていることを確認
        expect(response.body).to include(video.title)
      end

      it '一般公開ビデオも表示される' do
        # 視聴者としてログイン
        sign_in viewer
        get videos_path(organization_id: organization.id) 
        expect(response).to have_http_status(:ok)
        # レスポンスボディに一般公開ビデオのタイトルも含まれていることを確認
        expect(response.body).to include(public_video.title)
      end
    end

    context '視聴者がログインし、限定公開ビデオの閲覧権限がない場合' do
      it '一般公開ビデオのみが表示される' do
        # 別の視聴者としてログイン
        sign_in other_viewer
        get videos_path(organization_id: organization.id) 
        expect(response).to have_http_status(:ok)
        # レスポンスボディに一般公開ビデオのタイトルが含まれていることを確認
        expect(response.body).to include(public_video.title)
      end

      it '限定公開ビデオは表示されない' do
        # 別の視聴者としてログイン
        sign_in other_viewer
        get videos_path(organization_id: organization.id) 
        expect(response).to have_http_status(:ok)
        # レスポンスボディに限定公開ビデオのタイトルが含まれていないことを確認
        expect(response.body).not_to include(video.title)
      end
    end
  end
end