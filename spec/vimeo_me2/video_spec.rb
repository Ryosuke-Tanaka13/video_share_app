require 'spec_helper'
require 'vimeo_me2'

describe VimeoMe2::Video do
  before(:each) do
    # vcrを使って、仮想的にapiに動画データをアップロード。この時のリクエストやレスポンスの詳細は、vimeo-video.ymlに記載してある
    VCR.use_cassette('vimeo-video') do
      @own_video = VimeoMe2::Video.new(ENV['VIMEO_API_TOKEN'], '757851426')
      @delete_video = VimeoMe2::Video.new(ENV['VIMEO_API_TOKEN'], '757857700')
    end
  end

  context 'methods' do
    it 'returns the correct name' do
      expect(@own_video.name).to eq('rec.webm')
    end

    it 'is posisble to delete an existing video' do
      # vcrを使って、仮想的にapi内の動画データを削除。この時のリクエストやレスポンスの詳細は、vimeo-video-delete.ymlに記載してある
      VCR.use_cassette('vimeo-video-delete') do
        @delete_video.destroy
      end
      expect(@delete_video.video).to be_nil
    end
  end
end
