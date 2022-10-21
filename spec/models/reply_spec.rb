require 'rails_helper'

RSpec.describe Reply, type: :model do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:video) { create(:video, organization_id: organization.id, user_id: user.id) }
  let(:comment) { create(:comment, organization_id: organization.id, video_id: video.id) }
  let(:user_reply) { create(:user_reply, organization_id: user.organization_id, comment_id: comment.id) }
  let(:viewer_reply) { create(:viewer_reply, organization_id: user.organization_id, comment_id: comment.id) }

  before(:each) do
    organization
    user
    viewer
    video
    comment
    user_reply
    viewer_reply
  end

  describe '正常' do
    context 'userの場合' do
      it '正常に保存できること' do
        expect(user_reply).to be_valid
      end
    end

    context 'viewerの場合' do
      it '正常に保存できること' do
        expect(viewer_reply).to be_valid
      end
    end
  end

  describe 'バリデーション' do
    context 'userの場合' do
      it '空白' do
        user_reply.reply = ''
        expect(user_reply.valid?).to eq(false)
        expect(user_reply.errors.full_messages).to include('Replyを入力してください')
      end
    end

    context 'viewerの場合' do
      it '空白' do
        viewer_reply.reply = ''
        expect(viewer_reply.valid?).to eq(false)
        expect(viewer_reply.errors.full_messages).to include('Replyを入力してください')
      end
    end
  end
end
