require 'rails_helper'
RSpec.describe Video, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id) }

  let(:video_sample) do
    create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id, folders: [folder_celeb, folder_tech])
  end
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb]) }
  let(:video_it) { create(:video_it, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }

  before(:each) do
    organization
    user_owner
    user_staff
    video_sample
    video_test
    video_deleted
    sleep 0.1
  end

  describe '正常' do
    it '正常値で保存可能' do
      expect(video_sample.valid?).to eq(true)
    end

    it '論理削除された動画なら同じタイトルでも保存可能' do
      video_sample.title = 'デリートビデオ'
      expect(video_sample.valid?).to eq(true)
    end
  end

  describe 'バリデーション' do
    describe 'タイトル' do
      it '空白' do
        video_sample.title = ''
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('タイトルを入力してください')
      end

      it '重複' do
        video_sample.title = 'テストビデオ'
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('タイトルはすでに存在します')
      end
    end

    describe '組織ID' do
      it '空白' do
        video_sample.organization_id = ''
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('組織を入力してください')
      end
    end

    describe '投稿者ID' do
      it '空白' do
        video_sample.user_id = ''
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('投稿者を入力してください')
      end
    end

    describe '動画データ' do
      it '動画データが空白' do
        video_sample.video = nil
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('ビデオを入力してください')
      end

      it '動画データ以外のファイル' do
        video_sample.video = fixture_file_upload('/default.png')
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('ビデオのファイル形式が不正です。')
      end
    end
  end
end
