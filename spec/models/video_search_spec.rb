require 'rails_helper'

RSpec.describe Video, type: :model do
  subject { described_class.new }

  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user_owner) { create(:user_owner, organization: organization) }
  let(:user_staff) { create(:user_staff, organization: organization) }
  let(:user_staff1) { create(:user_staff1, organization: organization) }
  let(:video_jan_public_owner) { create(:video_jan_public_owner, organization: organization, user: user_owner) }
  let(:video_feb_private_owner) { create(:video_feb_private_owner, organization: organization, user: user_owner) }
  let(:video_mar_public_staff) { create(:video_mar_public_staff, organization: organization, user: user_staff) }
  let(:video_apr_private_staff) { create(:video_apr_private_staff, organization: organization, user: user_staff) }
  let(:video_may_public_staff1) { create(:video_may_public_staff1, organization: organization, user: user_staff1) }

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
      context '満たすデータが存在する場合 (正常系)' do
        context '検索フォームが未入力の場合' do
          it 'すべての動画を含む配列を返すこと' do
            expect(described_class.search('')).to include(
              video_jan_public_owner, video_feb_private_owner,
              video_mar_public_staff, video_apr_private_staff,
              video_may_public_staff1
            )
          end
        end

        context 'タイトルが満たす場合' do
          it 'タイトル「テ」を含む配列を返すこと' do
            expect(described_class.search(title_like: 'テ')).to include(
              video_jan_public_owner, video_feb_private_owner,
              video_mar_public_staff, video_apr_private_staff,
              video_may_public_staff1
            )
          end

          it 'タイトル「テスト動画1月」を含む配列を返すこと' do
            expect(described_class.search(title_like: 'テスト動画1月')).to include(video_jan_public_owner)
          end
        end

        context '公開期間開始日時が2023-02-01 00:00の場合' do
          it '2023-02-01 00:00以降の配列を返すこと' do
            expect(described_class.search(open_period_from: '2023-02-01T00:00')).to include(
              video_feb_private_owner, video_mar_public_staff,
              video_apr_private_staff, video_may_public_staff1
            )
          end
        end

        context '公開期間終了日時が2023-01-31 23:59の場合' do
          it '2023-01-31 23:59以前の配列を含むこと' do
            expect(described_class.search(open_period_to: '2023-01-31T23:59')).to include(video_jan_public_owner)
          end
        end

        context '公開範囲「すべての動画」を選択した場合' do
          it 'すべての動画を含む配列を返すこと' do
            expect(described_class.search(range: 'all')).to include(
              video_jan_public_owner, video_feb_private_owner,
              video_mar_public_staff, video_apr_private_staff,
              video_may_public_staff1
            )
          end
        end

        context '動画投稿者を満たす場合' do
          it '動画投稿者「オ」を含む配列を返すこと' do
            expect(described_class.search(user_name: 'オ')).to include(
              video_jan_public_owner, video_feb_private_owner
            )
          end
        end
      end

      context '満たすデータが存在しない場合 (異常系)' do
        context 'タイトルを満たさない場合' do
          it '空の配列を返すこと' do
            expect(described_class.search(title_like: 'テスト動画10月')).to be_empty
          end
        end

        context '公開期間開始日時を満たさない場合' do
          it '空の配列を返すこと' do
            expect(described_class.search(open_period_from: '2023-06-01T00:00')).to be_empty
          end
        end

        context '公開期間終了日時を満たさない場合' do
          it '空の配列を返すこと' do
            expect(described_class.search(open_period_to: '2023-01-31T23:58')).to be_empty
          end
        end

        context '動画投稿者を満たさない場合' do
          it '空の配列を返すこと' do
            expect(described_class.search(user_name: 'オーナー10')).to be_empty
          end
        end

        context 'タイトル、公開期間開始日時どちらも満たさない場合' do
          it '空の配列を返すこと' do
            expect(described_class.search(title_like: 'テスト動画10月', open_period_from: '2023-06-01T00:00')).to be_empty
          end
        end

        context '公開範囲のみ満たす場合' do
          it '空の配列を返すこと' do
            expect(described_class.search(title_like: 'テスト動画10月', range: 'all')).to be_empty
          end
        end

        context 'タイトル、公開期間、動画投稿者いずれも満たさない場合' do
          it '空の配列を返すこと' do
            expect(described_class.search(title_like: 'テスト動画10月', open_period_from: '2023-06-01T00:00',
              open_period_to: '2022-12-31T23:59', user_name: 'オーナー10')).to be_empty
          end
        end
      end
    end
  end
end
