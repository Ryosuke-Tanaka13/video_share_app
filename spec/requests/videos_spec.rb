require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:organization) { create(:organization) }
  let(:another_organization) { create(:another_organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id, confirmed_at: Time.now) }
  let(:user) { create(:user, organization_id: organization.id, confirmed_at: Time.now) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  before(:each) do
    organization
    another_organization
    user_owner
    another_user_owner
    user
    video_sample
  end

  describe 'GET #index' do
    describe '正常(動画投稿者)' do
      before(:each) do
        sign_in user
        get videos_path
      end
        
      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(オーナー)' do
      before(:each) do
        sign_in user_owner
        get videos_path
      end
        
      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '異常' do
      before(:each) do
        get videos_path
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET #new' do
    describe '正常(動画投稿者)' do
      before(:each) do
        sign_in user
        get new_video_path
      end
        
      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(オーナー)' do
      before(:each) do
        sign_in user_owner
        get new_video_path
      end
        
      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '異常' do
      before(:each) do
        get new_video_path
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST #create' do
    describe '正常(動画投稿者)' do
      before(:each) do
        sign_in user
      end

      it '動画が新規作成される' do
        expect {
          post videos_path,
            params: {
              video: {
                title: 'サンプルビデオ2',
                video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                open_period: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                range: false, 
                comment_public: false, 
                popup_before_video: false,
                popup_after_video: false,
                organization_id: 1, 
                user_id: 1 
              }
            }
        }.to change(Video, :count).by(1)
      end

      it 'indexにリダイレクトされる' do
        expect(
          post(videos_path, 
            params: {
              video: {
                title: 'サンプルビデオ2',
                video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                open_period: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                range: false,
                comment_public: false, 
                popup_before_video: false,
                popup_after_video: false,
                organization_id: 1, 
                user_id: 1 
              }
            })
        ).to redirect_to videos_path
      end
    end

    describe '正常(動画投稿者)' do
      before(:each) do
        sign_in user_owner
      end

      it '動画が新規作成される' do
        expect {
          post videos_path,
            params: {
              video: {
                title: 'サンプルビデオ2',
                video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                open_period: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                range: false, 
                comment_public: false, 
                popup_before_video: false,
                popup_after_video: false,
                organization_id: 1, 
                user_id: 1 
              }
            }
        }.to change(Video, :count).by(1)
      end

      it 'indexにリダイレクトされる' do
        expect(
          post(videos_path, 
            params: {
              video: {
                title: 'サンプルビデオ2',
                video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                open_period: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                range: false,
                comment_public: false, 
                popup_before_video: false,
                popup_after_video: false,
                organization_id: 1, 
                user_id: 1 
              }
            })
        ).to redirect_to videos_path
      end
    end

    describe '異常' do
      before(:each) do
        sign_in user
      end

      it 'タイトルが空白だと新規作成されない' do
        expect {
          post videos_path,
            params: {
              video: {
                title: '',
                video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                organization_id: 1, 
                user_id: 1 
              }
            }
        }.not_to change(Video, :count)
      end

      it 'タイトルが重複していると新規作成されない' do
        expect {
          post videos_path,
            params: {
              video: {
                title: 'サンプルビデオ',
                video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                organization_id: 1, 
                user_id: 1 
              }
            }
        }.not_to change(Video, :count)
      end

      it '動画が空白だと新規作成されない' do
        expect {
          post videos_path,
            params: {
              video: {
                title: 'サンプルビデオ',
                organization_id: 1, 
                user_id: 1 
              }
            }
        }.not_to change(Video, :count)
      end

      it '登録失敗するとエラーを出す' do
        expect(
          post(videos_path,
            params: {
              video: {
                title: ''
              }
            })
        ).to render_template :new
      end
    end
  end
  
  describe 'GET #show' do
    describe '正常' do
      before(:each) do
        get video_path(video_sample)
      end
        
      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end
  end

  # editとupdateは、アクションの処理を未作成なのでテスト未実施

  describe 'DELETE #destroy' do
    describe 'オーナーが現在のログインユーザー' do
      before(:each) do
        sign_in user_owner 
      end

      describe '正常' do
        it '動画を削除する' do
          expect {
            delete video_path(video_sample), params: { id: video_sample.id }
          }.to change(Video, :count).by(-1)
        end
       
        it 'indexにリダイレクトされる' do
          expect(
            delete(video_path(video_sample), params: { id: video_sample.id })
          ).to redirect_to videos_path
        end
      end
    end

    describe '別組織のオーナが現在のログインユーザ' do
      before(:each) do
        sign_in another_user_owner
      end

      describe '異常' do
        it '別組織のオーナは削除できない' do
          expect {
            delete video_path(video_sample), params: { id: video_sample.id }
          }.not_to change(Video, :count)
        end
      end
    end
  end
end
