require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id) }

  let(:video_sample) do
    create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id, folders: [folder_celeb])
  end
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb]) }
  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }

  before(:each) do
    organization
    user_owner
    user_staff
    video_test
    video_sample
    folder_celeb
    sleep 0.1
  end

  describe '正常系' do
    it '正常なデータで保存可能' do
      expect(video_sample.valid?).to eq(true)
    end
  end

  describe '異常系' do
    describe 'タイトルのバリデーション' do
      it 'タイトルが空白の場合、無効であること' do
        video_sample.title = ''
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('タイトルを入力してください')
      end

      it 'タイトルが重複する場合、無効であること' do
        video_sample.title = 'テストビデオ'
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('タイトルはすでに存在します')
      end
    end

    describe '組織IDのバリデーション' do
      it '組織IDが空白の場合、無効であること' do
        video_sample.organization_id = nil
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('組織を入力してください')
      end
    end

    describe '投稿者IDのバリデーション' do
      it '投稿者IDが空白の場合、無効であること' do
        video_sample.user_id = nil
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('投稿者を入力してください')
      end
    end

    describe '動画データのバリデーション' do
      it '動画データが空白の場合、無効であること' do
        video_sample.video = nil
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('ビデオを入力してください')
      end

      it '動画データ以外のファイルが設定された場合、無効であること' do
        video_sample.video = fixture_file_upload('/default.png')
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('ビデオのファイル形式が不正です。')
      end
    end
  end
end
