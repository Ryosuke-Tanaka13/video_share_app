require 'rails_helper'

RSpec.describe Reply, type: :model do
  let!(:user_reply) { FactoryBot.build(:user_reply) }
  let!(:viewer_reply) { FactoryBot.build(:viewer_reply) }

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