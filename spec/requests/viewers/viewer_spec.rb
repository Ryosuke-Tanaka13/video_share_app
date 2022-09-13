require 'rails_helper'

RSpec.describe 'Viewer', type: :request do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_owner
    user
    system_admin
    viewer
    viewer1
  end

  describe 'GET #index' do
    describe '正常(システム管理者)' do
      before(:each) do
        login_session(system_admin)
        current_system_admin(system_admin)
        get viewers_path(system_admin)
      end

      it 'レスポンスに成功する' do
        expect(response).to be_successful
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(オーナー)' do
      before(:each) do
        login_session(user_owner)
        current_user(user_owner)
        get viewers_path(user_owner)
      end

      it 'レスポンスに成功する' do
        expect(response).to be_successful
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(スタッフ)' do
      before(:each) do
        login_session(user)
        current_user(user)
        get viewers_path(user)
      end

      it 'レスポンスに成功する' do
        expect(response).to be_successful
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '異常(viewer)' do
      before(:each) do
        login_session(viewer)
        current_viewer(viewer)
        get viewers_path(viewer)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end

    describe '異常(ログインなし)' do
      before(:each) do
        get viewers_path
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST #create' do
    describe '正常' do
      before(:each) do
        new_viewer_path
      end

      it '視聴者が新規作成される' do
        expect {
          post viewers_path,
            params: {
              viewer: {
                name:                  '視聴者1',
                email:                 'sample1@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
        }.to change(Viewer, :count).by(1)
      end

      it 'ログイン画面にリダイレクトされる' do
        expect(
          post(viewers_path,
            params: {
              viewer: {
                name:                  'オーナー1',
                email:                 'sample1@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
          )
        ).to redirect_to viewer_session_path
      end
    end

    describe '異常' do
      before(:each) do
        new_viewer_path
      end

      it '入力が不十分だと新規作成されない' do
        expect {
          post viewers_path,
            params: {
              viewer: {
                name:                  ' ',
                email:                 'sample1@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
        }.to change(Viewer, :count).by(0)
      end

      it '登録失敗するとエラーを出す' do
        expect(
          post(viewers_path,
            params: {
              viewers: {
                name:                  '',
                email:                 '',
                password:              '',
                password_confirmation: ''
              }
            }
          )
        ).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    describe '視聴者情報の編集' do
      describe '本人の場合' do
        before(:each) do
          current_viewer(viewer)
        end

        describe '正常' do
          it '本人はアップデートできる' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'ユーザー',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { Viewer.find(viewer.id).name }.from(viewer.name).to('ユーザー')
          end
        end
      end

      describe 'オーナーの場合' do
        before(:each) do
          current_user(user_owner)
        end

        describe '異常' do
          it 'オーナはアップデートできない' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Viewer.find(viewer.id).name }
          end
        end
      end

      describe 'スタッフの場合' do
        before(:each) do
          current_user(user)
        end

        describe '異常' do
          it 'オーナはアップデートできない' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Viewer.find(viewer.id).name }
          end
        end
      end

      describe 'システム管理者の場合' do
        before(:each) do
          current_system_admin(system_admin)
        end

        describe '異常' do
          it 'オーナはアップデートできない' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Viewer.find(viewer.id).name }
          end
        end
      end

      describe '他視聴者の場合' do
        before(:each) do
          current_viewer(viewer1)
        end

        describe '異常' do
          it 'オーナはアップデートできない' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Viewer.find(viewer.id).name }
          end
        end
      end

      describe 'ログインなしの場合' do
        describe '異常' do
          it 'オーナはアップデートできない' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Viewer.find(viewer.id).name }
          end
        end
      end
    end
  end

  describe 'GET #show' do
    describe '視聴者詳細' do
      describe 'システム管理者の場合' do
        describe '正常' do
          before(:each) do
            current_system_admin(system_admin)
            get viewer_path(viewer)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '本人の場合' do
        describe '正常' do
          before(:each) do
            current_viewer(viewer)
            get viewer_path(viewer)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe 'オーナーの場合' do
        describe '異常' do
          before(:each) do
            current_user(user_owner)
            get viewer_path(viewer)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe 'スタッフの場合' do
        describe '異常' do
          before(:each) do
            current_user(user)
            get viewer_path(viewer)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '他視聴者の場合' do
        describe '異常' do
          before(:each) do
            current_viewer(viewer1)
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe 'ログインなしの場合' do
        describe '異常' do
          before(:each) do
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    describe 'システム管理者の場合' do
      before(:each) do
        current_system_admin(system_admin)
      end

      describe '正常' do
        it 'ユーザーを削除する' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.to change(Viewer, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to viewers_path
        end
      end
    end

    describe 'オーナーの場合' do
      before(:each) do
        current_user(user_owner)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_path
        end
      end
    end

    describe 'スタッフの場合' do
      before(:each) do
        current_user(user)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_path
        end
      end
    end

    describe '本人の場合' do
      before(:each) do
        current_viewer(viewer)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_path
        end
      end
    end

    describe '他視聴者の場合' do
      before(:each) do
        current_viewer(viewer1)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_path
        end
      end
    end

    describe 'ログインなしの場合' do
      describe '異常' do
        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_path
        end
      end
    end
  end
end
