require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:organization) { create(:test_organization) }
  let(:user) { create(:test_user, confirmed_at: Time.now) }
  let(:group) { create(:group) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let!(:viewer_group) { create(:viewer_group, viewer: viewer, group: group) }
  let!(:organization_viewer) { create(:organization_viewer, viewer: viewer, organization: organization) } 
  let!(:video) { create(:test_video, user: user, organization: organization, groups: [group], range: true) } # range: true は限定公開
  describe 'GET /videos' do
    context '視聴者がログインしている場合' do
      it 'ビデオが表示される' do
        # 視聴者としてログイン
        sign_in viewer
        get videos_path(organization_id: organization.id) 
        expect(response).to have_http_status(:ok)
        # レスポンスボディにビデオのタイトルが含まれていることを確認
        expect(response.body).to include(video.title)
      end
    end
  end
end