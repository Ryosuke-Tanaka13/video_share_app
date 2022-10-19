require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id) }
  let(:video_it) { create(:video_it, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  before(:each) do
    organization
    user_owner
    sleep 0.1
  end

  describe '正常' do
    it '正常値で保存可能' do
      expect(video_sample.valid?).to eq(true)
    end
  end

  describe 'バリデーション' do
    describe 'タイトル' do
      before(:each) do
        video_it
      end

      it '空白' do
        video_test.title = ''
        expect(video_test.valid?).to eq(false)
        expect(video_test.errors.full_messages).to include('タイトルを入力してください')
      end

      it '重複' do
        video_test.title = 'ITビデオ'
        expect(video_test.valid?).to eq(false)
        expect(video_test.errors.full_messages).to include('タイトルはすでに存在します')
      end
    end

    describe '組織ID' do
      it '空白' do
        video_test.organization_id = ''
        expect(video_test.valid?).to eq(false)
        expect(video_test.errors.full_messages).to include('組織を入力してください')
      end
    end

    describe '投稿者ID' do
      it '空白' do
        video_test.user_id = ''
        expect(video_test.valid?).to eq(false)
        expect(video_test.errors.full_messages).to include('投稿者を入力してください')
      end
    end

    describe '動画データ' do
      it '空白または動画以外のファイル' do
        video_test.data_url = nil
        expect(video_test.valid?).to eq(false)
        expect(video_test.errors.full_messages).to include('動画データをアップロードしてください')
      end
    end
  end
end
