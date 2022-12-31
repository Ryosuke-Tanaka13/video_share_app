require 'rails_helper'

RSpec.xdescribe 'VideoStatusHiddenSystem', type: :system, js: true do
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

  context '動画論理削除' do
    describe '正常' do
      context 'システム管理者orオーナー' do
        before(:each) do
          sign_in system_admin || user_owner
          visit video_status_hidden_path(video_sample_status, video_id: video_sample.id)
        end

        it 'レイアウト' do
          expect(page).to have_link '削除しない', href: video_statuses_path(video_sample)
          expect(page).to have_link '削除する', href: video_status_withdraw_path(video_sample_status, video_id: video_sample.id)
        end

        it '視聴状況一覧ページへ遷移' do
          click_link '削除しない'
          expect(page).to have_current_path video_statuses_path(video_sample), ignore_query: true
        end

        it '論理削除する' do
          expect {
            click_link '削除する'
          }.to change { VideoStatus.find(video_sample_status.id).is_valid }.from(video_sample_status.is_valid).to(false)
        end
      end
    end
  end
end
