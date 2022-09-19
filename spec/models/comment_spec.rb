require 'rails_helper'

RSpec.describe Comment, type: :model do
  let!(:user_comment) { FactoryBot.build(:user_comment) }
  let!(:viewer_comment) { FactoryBot.build(:viewer_comment) }

  describe '正常' do
    context 'userの場合' do
      it '正常に保存できること' do
        expect(user_comment).to be_valid
      end
    end
    context 'viewerの場合' do
      it '正常に保存できること' do
        expect(viewer_comment).to be_valid
      end
    end
  end

  describe 'バリデーション' do
    context 'userの場合' do
      it '空白' do
        user_comment.comment = ''
        expect(user_comment.valid?).to eq(false)
        expect(user_comment.errors.full_messages).to include('Commentを入力してください')
      end
    end
    context 'viewerの場合' do
      it '空白' do
        viewer_comment.comment = ''
        expect(viewer_comment.valid?).to eq(false)
        expect(viewer_comment.errors.full_messages).to include('Commentを入力してください')
      end
    end
  end
end