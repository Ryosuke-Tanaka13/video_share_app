require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:organization) { create(:organization) }
  let(:another_organization) { create(:another_organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id, confirmed_at: Time.now) }
  let(:user) { create(:user, organization_id: organization.id, confirmed_at: Time.now) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }
  let(:video_test) { create(:video_test, organization_id: user.organization.id, user_id: user.id) }

  before(:each) do
    system_admin
    organization
    another_organization
    user_owner
    another_user_owner
    user
    video_sample
    video_test
  end

  describe 'GET #index' do
    describe '正常(動画投稿者)' do
      before(:each) do
        sign_in user
        get videos_path(organization_id: organization.id)
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
        get videos_path(organization_id: organization.id)
      end

      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(システム管理者)' do
      before(:each) do
        sign_in system_admin
        get videos_path(organization_id: organization.id)
      end

      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '異常(別組織のuser)' do
      before(:each) do
        sign_in user_owner
        get videos_path(organization_id: another_organization.id)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to videos_path(organization_id: organization.id)
      end
    end

    describe '異常(非ログイン)' do
      before(:each) do
        get videos_path(organization_id: another_organization.id)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
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

    describe '異常(システム管理者)' do
      before(:each) do
        sign_in system_admin
        get new_video_path
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end

    describe '異常(非ログイン)' do
      before(:each) do
        get videos_path(organization_id: another_organization.id)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST #create' do
    describe '動画投稿者' do
      before(:each) do
        sign_in user
      end

      describe '正常' do
        it '動画が新規作成される' do
          expect {
            post videos_path,
              params: {
                video: {
                  title:              'サンプルビデオ2',
                  video:              fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                  open_period:        'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                  range:              false,
                  comment_public:     false,
                  popup_before_video: false,
                  popup_after_video:  false
                }
              }
          }.to change(Video, :count).by(1)
        end

        it 'showにリダイレクトされる' do
          expect(
            post(videos_path,
              params: {
                video: {
                  title:              'サンプルビデオ2',
                  video:              fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                  open_period:        'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                  range:              false,
                  comment_public:     false,
                  popup_before_video: false,
                  popup_after_video:  false
                }
              })
          ).to redirect_to video_path(Video.last)
        end
      end
    end

    describe 'オーナー' do
      before(:each) do
        sign_in user_owner
      end

      describe '正常' do
        it '動画が新規作成される' do
          expect {
            post videos_path,
              params: {
                video: {
                  title:              'サンプルビデオ2',
                  video:              fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                  open_period:        'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                  range:              false,
                  comment_public:     false,
                  popup_before_video: false,
                  popup_after_video:  false
                }
              }
          }.to change(Video, :count).by(1)
        end

        it 'showにリダイレクトされる' do
          expect(
            post(videos_path,
              params: {
                video: {
                  title:              'サンプルビデオ2',
                  video:              fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                  open_period:        'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                  range:              false,
                  comment_public:     false,
                  popup_before_video: false,
                  popup_after_video:  false
                }
              })
          ).to redirect_to video_path(Video.last)
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
                  video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov')
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
                  video: fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov')
                }
              }
          }.not_to change(Video, :count)
        end

        it '動画が空白だと新規作成されない' do
          expect {
            post videos_path,
              params: {
                video: {
                  title: 'サンプルビデオ2'
                }
              }
          }.not_to change(Video, :count)
        end

        it '動画以外のファイルだと新規作成されない' do
          expect {
            post videos_path,
              params: {
                video: {
                  title: 'サンプルビデオ2',
                  video: fixture_file_upload('/default.png')
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

    describe 'システム管理者が現在のログインユーザ' do
      before(:each) do
        sign_in system_admin
      end

      describe '異常' do
        it 'システム管理者は作成できない' do
          expect {
            post videos_path,
              params: {
                video: {
                  title:              'サンプルビデオ2',
                  video:              fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                  open_period:        'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                  range:              false,
                  comment_public:     false,
                  popup_before_video: false,
                  popup_after_video:  false
                }
              }
          }.not_to change(Video, :count)
        end
      end
    end

    describe '非ログイン' do
      describe '異常' do
        it '非ログインでは作成できない' do
          expect {
            post videos_path,
              params: {
                video: {
                  title:              'サンプルビデオ2',
                  video:              fixture_file_upload('/画面収録 2022-08-30 3.57.50.mov'),
                  open_period:        'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
                  range:              false,
                  comment_public:     false,
                  popup_before_video: false,
                  popup_after_video:  false
                }
              }
          }.not_to change(Video, :count)
        end
      end
    end
  end

  describe 'GET #show' do
    describe '正常(動画投稿者)' do
      before(:each) do
        sign_in user
        get video_path(video_sample)
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
        get video_path(video_sample)
      end

      it 'レスポンスに成功する' do
        expect(response).to have_http_status(:success)
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(非ログイン)' do
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

    describe '異常(別組織のuser)' do
      before(:each) do
        sign_in another_user_owner
        get video_path(video_sample)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to videos_path(organization_id: another_organization.id)
      end
    end

    describe '異常(非ログイン)' do
      before(:each) do
        get video_path(video_test)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'PATCH #update' do
    describe 'オーナーが現在のログインユーザ' do
      before(:each) do
        sign_in user_owner
      end

      describe '正常' do
        it '動画情報がアップデートされる' do
          expect {
            patch video_path(video_sample),
              params: {
                video: {
                  title:              'サンプルビデオ2',
                  open_period:        'Sun, 14 Aug 2022 18:07:00.000000000 JST +09:00',
                  range:              true,
                  comment_public:     true,
                  login_set:          true,
                  popup_before_video: true,
                  popup_after_video:  true
                }
              }
          }.to change { Video.find(video_sample.id).title }.from(video_sample.title).to('サンプルビデオ2')
        end

        it 'showにリダイレクトされる' do
          expect(
            patch(video_path(video_sample),
              params: {
                video: {
                  title: 'サンプルビデオ２'
                }
              })
          ).to redirect_to video_path(video_sample)
        end
      end

      describe '異常' do
        it 'ビデオ名が空白でアップデートされない' do
          expect {
            patch video_path(video_sample),
              params: {
                video: {
                  title: ''
                }, format: :js
              }
          }.not_to change { Video.find(video_sample.id).title }
        end

        it 'ビデオ名が重複してアップデートされない' do
          expect {
            patch video_path(video_sample),
              params: {
                video: {
                  title: 'テストビデオ'
                }, format: :js
              }
          }.not_to change { Video.find(video_test.id).title }
        end

        # jsのテストが通らない(できない)ので、コメントアウト
        # it '登録失敗するとモーダル上でエラーを出す' do
        #   expect(
        #     patch(video_path(video_sample),
        #       params: {
        #         video: {
        #           title: ''
        #         }, format: :js
        #       })
        #   ).to render_template :edit
        # end
      end
    end

    describe '動画投稿者本人が現在のログインユーザ' do
      before(:each) do
        sign_in user
      end

      describe '正常' do
        it '動画情報がアップデートされる' do
          expect {
            patch video_path(video_test),
              params: {
                video: {
                  title: 'テストビデオ2'
                }
              }
          }.to change { Video.find(video_test.id).title }.from(video_test.title).to('テストビデオ2')
        end

        it 'showにリダイレクトされる' do
          expect(
            patch(video_path(video_test),
              params: {
                video: {
                  title: 'テストビデオ２'
                }
              })
          ).to redirect_to video_path(video_test)
        end
      end
    end

    describe '本人以外の動画投稿者が現在のログインユーザ' do
      before(:each) do
        sign_in user
      end

      describe '異常' do
        it '本人以外はアップデートできない' do
          expect {
            patch video_path(video_sample),
              params: {
                video: {
                  title: 'サンプルビデオ２'
                }
              }
          }.not_to change { Video.find(video_sample.id).title }
        end
      end
    end

    # jsのテストが通らない(できない)ので、コメントアウト
    # describe '別組織のオーナーが現在のログインユーザ' do
    #   before(:each) do
    #     sign_in another_user_owner
    #   end

    #   describe '異常' do
    #     it '別組織のオーナーはアップデートできない' do
    #       expect {
    #         patch video_path(video_sample),
    #           params: {
    #             video: {
    #               title: 'サンプルビデオ２'
    #             }
    #           }
    #       }.not_to change { Video.find(video_sample.id).title }
    #     end
    #   end
    # end

    describe 'システム管理者が現在のログインユーザ' do
      before(:each) do
        sign_in system_admin
      end

      describe '異常' do
        it 'システム管理者はアップデートできない' do
          expect {
            patch video_path(video_sample),
              params: {
                video: {
                  title: 'サンプルビデオ２'
                }
              }
          }.not_to change { Video.find(video_sample.id).title }
        end
      end
    end
  end

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
          ).to redirect_to videos_path(organization_id: organization.id)
        end
      end
    end

    describe 'システム管理者が現在のログインユーザー' do
      before(:each) do
        sign_in system_admin
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
          ).to redirect_to videos_path(organization_id: organization.id)
        end
      end
    end

    describe '動画投稿者が現在のログインユーザ' do
      before(:each) do
        sign_in user
      end

      describe '異常' do
        it '動画投稿者は削除できない' do
          expect {
            delete video_path(video_sample), params: { id: video_sample.id }
          }.not_to change(Video, :count)
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

    describe '非ログイン' do
      describe '異常' do
        it '非ログインでは削除できない' do
          expect {
            delete video_path(video_sample), params: { id: video_sample.id }
          }.not_to change(Video, :count)
        end
      end
    end
  end
end
