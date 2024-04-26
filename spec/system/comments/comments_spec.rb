require 'rails_helper'

RSpec.describe 'Comments', type: :system, js: true do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:video_it) { create(:video_it, organization_id: organization.id, user_id: user.id, login_set: false) }
  let(:user_staff1) { create(:user_staff1, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:organization_viewer) { create(:organization_viewer, organization_id: user.organization_id, viewer_id: viewer.id) }
  let(:another_viewer) { create(:another_viewer) }
  let(:system_admin_comment) do
    create(:system_admin_comment, organization_id: user.organization_id, video_id: video_it.id, user_id: user.id)
  end
  let(:user_comment) { create(:user_comment, organization_id: user.organization_id, video_id: video_it.id, user_id: user_staff1.id) }
  let(:viewer_comment) { create(:viewer_comment, organization_id: user.organization_id, video_id: video_it.id, viewer_id: viewer.id) }
  let(:system_admin_reply) do
    create(:system_admin_reply, system_admin_id: system_admin.id, organization_id: user.organization_id,
      comment_id: system_admin_comment.id)
  end

  before(:each) do
    organization
    system_admin
    user
    video_it
    user_staff1
    viewer
    organization_viewer
    another_viewer
    system_admin_comment
    user_comment
    viewer_comment
    sleep 0.1
  end

  describe '正常' do
    describe 'システム管理者' do
      before(:each) do
        sign_in system_admin
      end

      it 'レイアウト' do
        puts "現在のページのパス: #{current_path}"
      end
    end
  end
end
