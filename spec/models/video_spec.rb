require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }
  
  before(:each) do
    organization
    user_owner
    video_sample
    sleep 0.1
  end

  describe '正常' do
    it '正常値で保存可能' do
      video = Video.create(title:"サンプルビデオ2", organization_id: 1, user_id: 1 )
      video.video.attach(io: File.open('spec/fixtures/files/画面収録 2022-08-30 3.57.50.mov'), filename: '画面収録 2022-08-30 3.57.50.mov', content_type: 'video/mov')
      expect(video.valid?).to eq(true)
    end
  end

  describe 'バリデーション' do
    describe 'タイトル' do
      it '空白' do
        video = Video.create(title: nil, organization_id: 1, user_id: 1 ) 
        video.video.attach(io: File.open('spec/fixtures/files/画面収録 2022-08-30 3.57.50.mov'), filename: '画面収録 2022-08-30 3.57.50.mov', content_type: 'video/mov')
        video.valid?
        expect(video.errors.full_messages).to include('タイトルを入力してください')
      end

      it '重複' do
        video = Video.create(title: "サンプルビデオ", organization_id: 1, user_id: 1 ) 
        video.video.attach(io: File.open('spec/fixtures/files/画面収録 2022-08-30 3.57.50.mov'), filename: '画面収録 2022-08-30 3.57.50.mov', content_type: 'video/mov')
        video.valid?
        expect(video.errors.full_messages).to include('タイトルはすでに存在します')
      end
    end
    
    describe '組織ID' do
      it '空白' do
        video = Video.create(title: "サンプルビデオ2", organization_id: nil, user_id: 1 ) 
        video.video.attach(io: File.open('spec/fixtures/files/画面収録 2022-08-30 3.57.50.mov'), filename: '画面収録 2022-08-30 3.57.50.mov', content_type: 'video/mov')
        video.valid?
        expect(video.errors.full_messages).to include('組織を入力してください')
      end
    end
    
    describe '投稿者ID' do
      it '空白' do
        video = Video.create(title: "サンプルビデオ2", organization_id: 1, user_id: nil ) 
        video.video.attach(io: File.open('spec/fixtures/files/画面収録 2022-08-30 3.57.50.mov'), filename: '画面収録 2022-08-30 3.57.50.mov', content_type: 'video/mov')
        video.valid?
        expect(video.errors.full_messages).to include('投稿者を入力してください')
      end
    end

    describe 'ビデオ' do
      it '空白' do
        video = Video.create(title: "サンプルビデオ2", organization_id: 1, user_id: 1 ) 
        video.valid?
        expect(video.errors.full_messages).to include('ビデオを入力してください')
      end
    end
  end
end