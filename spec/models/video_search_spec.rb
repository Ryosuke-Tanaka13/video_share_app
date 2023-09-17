require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user_owner) { create(:user_owner) }
  let(:user_staff) { create(:user_staff) }
  let(:user_staff1) { create(:user_staff1) }
  let(:video_jan_public_owner) { create(:video_jan_public_owner) }
  let(:video_feb_private_owner) { create(:video_feb_private_owner) }
  let(:video_mar_public_staff) { create(:video_mar_public_staff) }
  let(:video_apr_private_staff) { create(:video_apr_private_staff) }
  let(:video_may_public_staff1) { create(:video_may_public_staff1) }

  before(:each) do
    organization
    system_admin
    user_owner
    user_staff
    user_staff1
    video_jan_public_owner
    video_feb_private_owner
    video_mar_public_staff
    video_apr_private_staff
    video_may_public_staff1
  end

  describe 'scope' do
    describe 'search' do
      context '満たすデータが存在する場合' do
        context '検索フォームが未入力の場合' do
          it '組織内の動画をすべて含む配列を返すこと' do
            expect(Video.search('')).to include(video_jan_public_owner, video_feb_private_owner, video_mar_public_staff, video_apr_private_staff, video_may_public_staff1)
          end
        end
        context 'タイトルが部分満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テ')).to include(video_jan_public_owner, video_feb_private_owner, video_mar_public_staff, video_apr_private_staff, video_may_public_staff1)
          end
          it '満たさない配列は返さないこと' do
            expect(Video.search(title_like: 'テスト動画1')).to_not include(video_feb_private_owner, video_mar_public_staff, video_apr_private_staff, video_may_public_staff1)
          end
        end
        context '公開期間開始日時が2023-02-01 00:00場合' do
          it '2023-02-01 00:00以降の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-02-01T00:00')).to include(video_feb_private_owner, video_mar_public_staff, video_apr_private_staff, video_may_public_staff1)
          end
        end
        context '公開期間終了日時が2023-01-31 23:59の場合' do
          it '2023-01-31 23:59よりも前の配列を含むこと' do
            expect(Video.search(open_period_to: '2023-01-31T23:59')).to include(video_jan_public_owner)
          end
        end
        context '「すべての動画」を選択した場合' do
          it 'すべての動画の配列を返すこと' do
            expect(Video.search(range: 'all')).to include(video_jan_public_owner, video_feb_private_owner, video_mar_public_staff, video_apr_private_staff, video_may_public_staff1)
          end
        end
        context '「一般公開のみ」を選択した場合' do
          it '一般公開の配列を返すこと' do
            expect(Video.search(range: 'true')).to include(video_jan_public_owner, video_mar_public_staff, video_may_public_staff1)
          end
        end
        context '「限定公開のみ」を選択した場合' do
          it '限定公開のみの配列を返すこと' do
            expect(Video.search(range: 'false')).to include(video_feb_private_owner, video_apr_private_staff)
          end
        end
        context '動画投稿者を満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(user_name: 'オ')).to include(video_jan_public_owner, video_feb_private_owner)
          end
        end
        context 'タイトル、公開期間開始日時ともに満たす場合' do
          it '満たす動配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-01-01T00:00')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テ', open_period_from: '2023-02-01T00:00')).to include(video_feb_private_owner, video_mar_public_staff, video_apr_private_staff, video_may_public_staff1)
          end
        end
        context 'タイトル、公開期間終了日時ともに満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_to: '2023-01-31T23:59')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テ', open_period_to: '2023-03-01T00:00')).to include(video_jan_public_owner, video_feb_private_owner)
          end
        end
        context 'タイトル、公開範囲ともに満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', range: 'all')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', range: 'true')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画2', range: 'false')).to include(video_feb_private_owner)
          end
        end
        context 'タイトル、動画投稿者ともに満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', user_name: 'オーナー')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画2', user_name: 'オ')).to include(video_feb_private_owner)
          end
          it '満たす動画の配列を返すこと' do
            expect(Video.search(title_like: 'テ', user_name: 'オ')).to include(video_jan_public_owner, video_feb_private_owner)
          end
        end
        context '公開期間、公開範囲ともに満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_from: '2023-02-01T00:00', range: 'all')).to include(video_feb_private_owner, video_mar_public_staff, video_apr_private_staff, video_may_public_staff1)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_from: '2023-01-01T00:00', range: 'true')).to include(video_jan_public_owner, video_mar_public_staff, video_may_public_staff1)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_from: '2023-01-01T00:00', range: 'false')).to include(video_feb_private_owner, video_apr_private_staff)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_to: '2023-01-31T23:59', range: 'all')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_to: '2023-01-31T23:59', range: 'true')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_to: '2023-02-28T23:59', range: 'false')).to include(video_feb_private_owner)
          end
        end
        context '公開期間、動画投稿者ともに満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_from: '2023-02-01T00:00', user_name: 'オーナー')).to include(video_feb_private_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_to: '2023-01-31T23:59', user_name: 'オ')).to include(video_jan_public_owner)
          end
        end
        context '公開範囲、動画投稿者ともに満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(range: 'all', user_name: 'オーナー')).to include(video_jan_public_owner, video_feb_private_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(range: 'true', user_name: 'オ')).to include(video_jan_public_owner)
          end
          it '満たす配列を返すこと' do
            expect(Video.search(range: 'false', user_name: 'オ')).to include(video_feb_private_owner)
          end
        end
        context 'タイトル、公開期間、公開範囲全てを満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'true')).to include(
              video_jan_public_owner)
          end
        end
        context 'タイトル、公開期間、動画投稿者全てを満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', user_name: 'オーナー')).to include(
              video_jan_public_owner)
          end
        end
        context '公開期間、公開範囲、動画投稿者全てを満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'true', user_name: 'オーナー')).to include(
              video_jan_public_owner)
          end
        end
        context '全てを満たす場合' do
          it '満たす配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'true', user_name: 'オーナー')).to include(
              video_jan_public_owner)
          end
        end
      end

      context '満たすデータが存在しない場合' do
        context 'タイトルが満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8')).to be_empty
          end
        end
        context '公開期間開始日時を満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-06-01T00:00')).to be_empty
          end
        end
        context '公開期間終了日時を満たさない場合' do 
          it '空の配列を返すこと' do
            expect(Video.search(open_period_to: '2023-01-31T23:58')).to be_empty
          end
        end
        context '動画投稿者を満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(user_name: 'オーナー1')).to be_empty
          end
          it '空の配列を返すこと' do
            expect(Video.search(user_name: 'オーナー1')).to be_empty
          end
        end
        context 'タイトル、公開期間開始日時どちらも満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画', open_period_from: '2023-06-01T00:00')).to be_empty
          end
        end
        context 'タイトル、公開期間開始日時どちらかのみ満たす場合' do
          it 'タイトルのみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テ', open_period_from: '2023-06-01T00:00')).to be_empty
          end
          it '公開期間開始日時のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-01-01T00:00')).to be_empty
          end
        end
        context 'タイトル、公開期間終了日時どちらも満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_to: '2022-12-31T23:59')).to be_empty
          end
        end
        context 'タイトル、公開期間終了日時どちらかのみ満たす場合' do
          it 'タイトルのみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テ', open_period_to: '2023-01-31T23:58')).to be_empty
          end
          it '公開期間終了日時のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_to: '2023-01-31T23:59')).to be_empty
          end
        end
        context 'タイトル、公開範囲どちらかのみ満たす場合' do
          it 'タイトルのみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', range: 'false')).to be_empty
          end
          it '公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', range: 'all')).to be_empty
          end
        end
        context 'タイトル、動画投稿者どちらも満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', user_name: 'オーナー1')).to be_empty
          end
        end
        context 'タイトル、動画投稿者どちらかのみ満たす場合' do
          it 'タイトルのみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', user_name: 'オーナー1')).to be_empty
          end
          it '動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', user_name: 'オーナー')).to be_empty
          end
        end
        context '公開期間開始日時、公開範囲どちらかのみ満たす場合' do
          it '公開期間開始日時のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-05-01T00:00', range: 'false')).to be_empty
          end
          it '公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-06-01T00:00', range: 'all')).to be_empty
          end
        end
        context '公開期間終了日時、公開範囲どちらかのみ満たす場合' do          
          it '公開期間終了日のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_to: '2023-01-31T23:59', range: 'false')).to be_empty
          end
          it '公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_to: '2022-12-31T23:59', range: 'true')).to be_empty
          end
        end
        context '公開期間開始日時、動画投稿者どちらも満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-06-01T00:00', user_name: 'オーナー1')).to be_empty
          end
        end
        context '公開期間開始日時、動画投稿者どちらかのみ満たす場合' do
          it '公開期間開始日時のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-01-01T00:00', user_name: 'オーナー1')).to be_empty
          end
          it '動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-06-01T00:00', user_name: 'オーナー')).to be_empty
          end
        end
        context '公開期間終了日時、動画投稿者どちらも満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(open_period_to: '2022-12-31T00:00', user_name: 'オーナー1')).to be_empty
          end
        end
        context '公開期間終了日時、動画投稿者どちらかのみ満たす場合' do
          it '公開期間終了日時のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_to: '2023-01-31T23:59', user_name: 'オーナー1')).to be_empty
          end
          it '動画投稿者のみ満たす場合' do
            expect(Video.search(open_period_to: '2022-12-31T23:59', user_name: 'オーナー')).to be_empty
          end
        end
        context '公開範囲、動画投稿者どちらかのみ満たす場合' do
          it '公開範囲のみ満たす場合、からの配列を返すこと' do
            expect(Video.search(range: 'all', user_name: 'オーナー1')).to be_empty
          end
        end
        context 'タイトル、公開期間、公開範囲いずれかのみ満たす場合' do
          it 'タイトルのみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-06-01T00:00', open_period_to: '2023-01-31T23:58', range: 'false')).to be_empty
          end
          it '公開期間のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'false')).to be_empty
          end
          it '公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', range: 'all')).to be_empty
          end
          it 'タイトル、公開期間のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'false')).to be_empty
          end
          it 'タイトル、公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', range: 'true')).to be_empty
          end
          it '公開期間、公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'true')).to be_empty
          end
        end
        context 'タイトル、公開期間、動画投稿者いずれかのみ満たす場合' do
          it 'タイトルのみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-06-01T00:00', open_period_to: '2023-01-31T23:58', user_name: 'オーナー1')).to be_empty
          end
          it '公開期間のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', user_name: 'オーナー1')).to be_empty
          end
          it '動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', user_name: 'オーナー')).to be_empty
          end
          it 'タイトル、公開期間のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', user_name: 'オーナー1')).to be_empty
          end
          it 'タイトル、動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画1', open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', user_name: 'オーナー')).to be_empty
          end
          it '公開期間、動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', user_name: 'オーナー')).to be_empty
          end
        end
        context '公開期間、公開範囲、動画投稿者いずれかのみ満たす場合' do
          it '公開期間のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'true', user_name: 'オーナー1')).to be_empty
          end
          it '公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', range: 'all', user_name: 'オーナー1')).to be_empty
          end
          it '動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', range: 'false', user_name: 'オーナー')).to be_empty
          end
          it '公開期間、公開範囲のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'true', user_name: 'オーナー1')).to be_empty
          end
          it '公開期間、動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-01-01T00:00', open_period_to: '2023-01-31T23:59', range: 'false', user_name: 'オーナー')).to be_empty
          end
          it '公開範囲、動画投稿者のみ満たす場合、空の配列を返すこと' do
            expect(Video.search(open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', range: 'true', user_name: 'オーナー')).to be_empty
          end
        end
        context 'rangeを除き満たさない場合' do
          it '空の配列を返すこと' do
            expect(Video.search(title_like: 'テスト動画8', open_period_from: '2023-06-01T00:00', open_period_to: '2022-12-31T23:59', range: 'all', user_name: 'オーナー1')).to be_empty
          end
        end
      end
    end
  end
end
