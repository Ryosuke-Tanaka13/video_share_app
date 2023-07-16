require 'rails_helper'

RSpec.describe VideoStatus, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }
  let(:viewer) { create(:viewer) }
  let(:video_sample_status) { build(:video_sample_status, video_id: video_sample.id, viewer_id: viewer.id) }

  before(:each) do
    organization
    user_owner
    video_sample
    viewer
    video_sample_status
  end

  describe '正常' do
    it '正常値で保存可能' do
      expect(video_sample_status.valid?).to eq(true)
    end
  end

  describe 'バリデーション' do
    describe '動画ID' do
      it '空白' do
        video_sample_status.video_id = ''
        expect(video_sample_status.valid?).to eq(false)
      end
    end

    describe '視聴者ID' do
      it '空白' do
        video_sample_status.viewer_id = ''
        expect(video_sample_status.valid?).to eq(false)
      end
    end
  end
end
