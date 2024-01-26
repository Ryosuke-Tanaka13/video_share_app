require 'rails_helper'

Rspec.xdescribe Comment, type: :model do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:video_it) { create(:video_it, organization_id: organization.id, user_id: user.id) }
  let(:system_admin_comment) do
    create(:system_admin_comment, organization_id: user.organization_id, video_id: video_it.id, system_admin_id: system_admin.id)
  end
  let(:user_comment) { create(:user_comment, organization_id: user.organization_id, video_id: video_it.id, user_id: user.id) }
  let(:viewer_comment) { create(:viewer_comment, organization_id: user.organization_id, video_id: video_it.id, viewer_id: viewer.id) }

  before(:each) do
    organization
    system_admin
    user
    viewer
    video_it
    system_admin_comment
    user_comment
    viewer_comment
  end

  describe '正常' do
    context 'システム管理者の場合' do
      it '正常に保存できること' do
        expect(system_admin_comment).to be_valid
      end
    end

    context '動画投稿者の場合' do
      it '正常に保存できること' do
        expect(user_comment).to be_valid
      end
    end

    context '動画視聴者の場合' do
      it '正常に保存できること' do
        expect(viewer_comment).to be_valid
      end
    end
  end

  describe 'バリデーション' do
    context 'システム管理者の場合' do
      it '空白' do
        system_admin_comment.comment = ''
        expect(system_admin_comment.valid?).to eq(false)
        expect(system_admin_comment.errors.full_messages).to include('Commentを入力してください')
      end
    end

    context '動画投稿者の場合' do
      it '空白' do
        user_comment.comment = ''
        expect(user_comment.valid?).to eq(false)
        expect(user_comment.errors.full_messages).to include('Commentを入力してください')
      end
    end

    context '動画視聴者の場合' do
      it '空白' do
        viewer_comment.comment = ''
        expect(viewer_comment.valid?).to eq(false)
        expect(viewer_comment.errors.full_messages).to include('Commentを入力してください')
      end
    end
  end
end
