require 'rails_helper'

RSpec.xdescribe VideoFolder, type: :model do
  let(:video_sample) { create(:video_sample) }
  let(:folder_celeb) { create(:folder_celeb) }
  let(:video_folder) { build(:video_folder, video_id: video_sample.id, folder_id: folder_celeb.id) }

  before(:each) do
    video_sample
    folder_celeb
  end

  xdescribe '正常' do
    it '正常値で保存可能' do
      expect(video_folder.valid?).to eq(true)
    end
  end

  xdescribe 'バリデーション' do
    xdescribe 'ビデオID' do
      it '空白' do
        video_folder.video_id = ''
        expect(video_folder.valid?).to eq(false)
        expect(video_folder.errors.full_messages).to include('Videoを入力してください')
      end
    end

    xdescribe 'フォルダーID' do
      it '空白' do
        video_folder.folder_id = ''
        expect(video_folder.valid?).to eq(false)
        expect(video_folder.errors.full_messages).to include('Folderを入力してください')
      end
    end
  end
end
