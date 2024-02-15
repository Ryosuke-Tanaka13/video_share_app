require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:group) { create(:group, organization: organization) }
  let(:viewer) { create(:viewer) }
  let!(:viewer_group) { create(:viewer_group, viewer: viewer, group: group) }
  let(:video) { create(:video_it, user: user, groups: [group], range: true) } # range: true は限定公開

  describe 'GET /videos' do
    context '視聴者がログインしている場合' do
      it 'ビデオが表示される' do
        # 視聴者としてログイン
        sign_in viewer

        # ビデオ一覧ページにアクセス
        get videos_path
        follow_redirect!
        # レスポンスが成功（200）であることを確認
        expect(response).to have_http_status(:ok)

        # レスポンスボディにビデオのタイトルが含まれていることを確認
        expect(response.body).to include(video.title)
      end
    end
  end
end