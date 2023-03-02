require 'rails_helper'

RSpec.xdescribe 'VideoHiddenSystem', type: :system, js: true do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user) { create(:user, organization_id: organization.id, confirmed_at: Time.now) }
  let(:video_sample) { create(:video_sample, organization_id: user.organization.id, user_id: user_owner.id) }

  before(:each) do
    system_admin
    organization
    user_owner
    user
    video_sample
  end

  context '動画論理削除' do
    describe '正常' do
      context 'システム管理者orオーナー' do
        before(:each) do
          sign_in system_admin || user_owner
          visit videos_hidden_path(video_sample)
        end

        it 'レイアウト' do
          expect(page).to have_link '削除しない', href: video_path(video_sample)
          expect(page).to have_link '削除する', href: videos_withdraw_path(video_sample)
        end

        it '詳細へ遷移' do
          click_link '削除しない'
          expect(page).to have_current_path video_path(video_sample), ignore_query: true
        end

        it '論理削除する' do
          expect {
            click_link '削除する'
          }.to change { Video.find(video_sample.id).is_valid }.from(video_sample.is_valid).to(false)
        end
      end
    end
  end
end
