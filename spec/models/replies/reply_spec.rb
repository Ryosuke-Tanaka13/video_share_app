require 'rails_helper'

RSpec.describe Reply, type: :model do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:video_it) { create(:video_it, organization_id: organization.id, user_id: user.id) }
  let(:comment) { create(:comment, organization_id: organization.id, video_id: video_it.id, user_id: user.id) }
  let(:system_admin_reply) do
    create(:system_admin_reply, organization_id: user.organization_id, comment_id: comment.id, system_admin_id: system_admin.id)
  end
  let(:user_reply) { create(:user_reply, organization_id: user.organization_id, comment_id: comment.id, user_id: user.id) }
  let(:viewer_reply) { create(:viewer_reply, organization_id: user.organization_id, comment_id: comment.id, viewer_id: viewer.id) }

  before(:each) do
    organization
    system_admin
    user
    viewer
    video_it
    comment
    system_admin_reply
    user_reply
    viewer_reply
    sleep 0.1
  end

  describe '正常' do
    context 'システム管理者の場合' do
      it '正常に保存できること' do
        expect(system_admin_reply).to be_valid
      end
    end

    context '動画投稿者の場合' do
      it '正常に保存できること' do
        expect(user_reply).to be_valid
      end
    end

    context '動画視聴者の場合' do
      it '正常に保存できること' do
        expect(viewer_reply).to be_valid
      end
    end
  end

  describe 'バリデーション' do
    context 'システム管理者の場合' do
      it '空白' do
        system_admin_reply.reply = ''
        expect(system_admin_reply.valid?).to eq(false)
        expect(system_admin_reply.errors.full_messages).to include('Replyを入力してください')
      end
    end

    context '動画投稿者の場合' do
      it '空白' do
        user_reply.reply = ''
        expect(user_reply.valid?).to eq(false)
        expect(user_reply.errors.full_messages).to include('Replyを入力してください')
      end
    end

    context '動画視聴者の場合' do
      it '空白' do
        viewer_reply.reply = ''
        expect(viewer_reply.valid?).to eq(false)
        expect(viewer_reply.errors.full_messages).to include('Replyを入力してください')
      end
    end
  end
end
