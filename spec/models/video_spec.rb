require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }
  let(:video_test) { create(:video_test, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  before(:each) do
    organization
    user_owner
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

    # describe 'ビデオ' do
    #   it '空白' do
    #     # factorybotを利用して、添付ビデオなしのインスタンスを作る方法がわからず、新たに生成することで対応
    #     video_not_have = Video.new(title: '添付ビデオなし', organization_id: 1, user_id: 1)
    #     expect(video_not_have.valid?).to eq(false)
    #     expect(video_not_have.errors.full_messages).to include('ビデオを入力してください')
    #   end
    # end
  end
end
