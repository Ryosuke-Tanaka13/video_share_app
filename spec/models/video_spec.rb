require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id, folders:[folder_celeb, folder_tech]) }
  let(:video_test) { create(:video_test, organization_id: user_owner.organization.id, user_id: user_owner.id, folders:[folder_celeb]) }

  before(:each) do
    organization
    user_owner
    folder_celeb
    folder_tech
    video_sample
    video_test
    sleep 0.1
  end

  describe '正常' do
    it '正常値で保存可能' do
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
        video_test.title = 'サンプルビデオ'
        expect(video_test.valid?).to eq(false)
        expect(video_test.errors.full_messages).to include('タイトルはすでに存在します')
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

    describe 'ビデオ' do
      it '空白' do
        video_sample.video = nil
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('ビデオを入力してください')
      end

      it 'ビデオファイル以外' do
        video_sample.video = fixture_file_upload('/default.png')
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('ビデオのファイル形式が不正です。')
      end
    end

    describe 'フォルダー割り振り' do
      it '選択なし' do
        video_sample.folders = []
        expect(video_sample.valid?).to eq(false)
        expect(video_sample.errors.full_messages).to include('フォルダー割り振りを入力してください')
      end
    end
  end
end
