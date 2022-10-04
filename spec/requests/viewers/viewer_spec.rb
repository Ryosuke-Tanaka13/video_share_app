require 'rails_helper'

RSpec.describe 'Viewer', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }

  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer1) { create(:organization_viewer1) }
  let(:organization_viewer2) { create(:organization_viewer2) }
  let(:organization_viewer3) { create(:organization_viewer3) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    organization_viewer
    organization_viewer1
    organization_viewer2
    organization_viewer3
  end

  # システム管理者　投稿者　のみ許可
  describe 'GET #index' do
    describe '正常' do
      context 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get viewers_path(organization_id: organization.id)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end

      context 'オーナー' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get viewers_path(organization_id: organization.id)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end

      context 'スタッフ' do
        before(:each) do
          login_session(user_staff)
          current_user(user_staff)
          get viewers_path(organization_id: organization.id)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end
    end

    describe '異常' do
      context '視聴者' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
          get viewers_path(organization_id: organization.id)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end

      context 'ログインなし' do
        before(:each) do
          get viewers_path(organization_id: organization.id)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end
    end
  end

  # GET #new deviseのみ

  # POST #create deviseのみ

  # システム管理者　set_viewerと同組織オーナー　視聴者本人　のみ許可
  describe 'GET #show' do
    context '視聴者詳細' do
      describe '正常' do
        context 'システム管理者' do
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

        context '同組織オーナー' do
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

        context '本人' do
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

      describe '異常' do
        context '別組織オーナー' do
          before(:each) do
            current_user(another_user_owner)
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_url
          end
        end

        context '同組織スタッフ' do
          before(:each) do
            current_user(user_staff)
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_url
          end
        end

        context '別組織スタッフ' do
          before(:each) do
            current_user(another_user_staff)
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_url
          end
        end

        context '同組織他視聴者' do
          before(:each) do
            current_viewer(viewer1)
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_url
          end
        end

        context '他組織視聴者' do
          before(:each) do
            current_viewer(another_viewer)
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_url
          end
        end

        context 'ログインなし' do
          before(:each) do
            get viewer_path(viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_url
          end
        end
      end
    end
  end

  # システム管理者　set_viewerと同組織オーナー　視聴者本人　のみ許可
  describe 'GET #edit' do
    describe '正常' do
      context 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
          get edit_viewer_path(viewer)
        end

        it 'レスポンスに成功する' do
          expect(response).to have_http_status(:success)
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end

      context '本人' do
        before(:each) do
          current_viewer(viewer)
          get edit_viewer_path(viewer)
        end

        it 'レスポンスに成功する' do
          expect(response).to have_http_status(:success)
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end

      context '同組織オーナー' do
        before(:each) do
          current_user(user_owner)
          get edit_viewer_path(viewer)
        end

        it 'レスポンスに成功する' do
          expect(response).to have_http_status(:success)
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end
    end

    describe '異常' do
      context '同組織スタッフ' do
        before(:each) do
          current_user(user_staff)
          get edit_viewer_path(viewer)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end

      context '別組織オーナー' do
        before(:each) do
          current_user(another_user_owner)
          get edit_viewer_path(viewer)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end

      context '別組織スタッフ' do
        before(:each) do
          current_user(another_user_staff)
          get edit_viewer_path(viewer)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end

      context '同組織他視聴者' do
        before(:each) do
          current_viewer(viewer1)
          get edit_viewer_path(viewer)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end

      context '他組織視聴者' do
        before(:each) do
          current_viewer(another_viewer)
          get edit_viewer_path(viewer)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end

      context 'ログインなし' do
        before(:each) do
          get edit_viewer_path(viewer)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status '302'
          expect(response).to redirect_to root_url
        end
      end
    end
  end

  # システム管理者　set_viewerと同組織オーナー　視聴者本人　のみ許可
  describe 'PATCH #update' do
    context '視聴者更新（権限チェック）' do
      describe '正常' do
        context '本人' do
          before(:each) do
            current_viewer(viewer)
          end

          context '正常' do
            it 'アップデートできる' do
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

        context 'システム管理者' do
          before(:each) do
            current_system_admin(system_admin)
          end

          it 'アップデートできる' do
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

        context '同組織オーナー' do
          before(:each) do
            current_user(user_owner)
          end

          it 'アップデートできる' do
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

      describe '異常' do
        context '同組織スタッフ' do
          before(:each) do
            current_user(user_staff)
          end

          it 'アップデートできない' do
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

        context '他組織オーナー' do
          before(:each) do
            current_user(another_user_owner)
          end

          it 'アップデートできない' do
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

        context '他組織スタッフ' do
          before(:each) do
            current_user(another_user_staff)
          end

          it 'アップデートできない' do
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

        context '同組織他視聴者' do
          before(:each) do
            current_viewer(viewer1)
          end

          it 'アップデートできない' do
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

        context '他組織視聴者' do
          before(:each) do
            current_viewer(another_viewer)
          end

          it 'アップデートできない' do
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

        context 'ログインなし' do
          it 'アップデートできない' do
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

    context '視聴者更新（動作）' do
      context '本人' do
        before(:each) do
          edit_viewer_path(viewer)
          current_viewer(viewer)
        end

        describe '正常' do
          # emailの更新については認証が必要
          it '名前がアップデートされる' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'ユーザー',
                    email: 'sample@email.com'
                  }
                }
            }.to change { Viewer.find(viewer.id).name }.from(viewer.name).to('ユーザー')
          end

          it 'indexにリダイレクトされる' do
            expect(
              patch(viewer_path(viewer),
                params: {
                  viewer: {
                    name: 'ユーザー'
                  }
                })
            ).to redirect_to viewer_url(viewer)
          end
        end

        describe '異常' do
          it '名前が空白でアップデートされない' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  ' ',
                    email: 'sample@email.com'
                  }
                }
            }.not_to change { Viewer.find(viewer.id).name }
          end

          it 'email更新時、認証なしではアップデートされない' do
            expect {
              patch viewer_path(viewer),
                params: {
                  viewer: {
                    name:  'viewer',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Viewer.find(viewer.id).email }
          end

          it '登録失敗するとエラーを出す' do
            expect(
              patch(viewer_path(viewer),
                params: {
                  viewer: {
                    name: ' '
                  }
                })
            ).to render_template :edit
          end
        end
      end
    end
  end

  # システム管理者　のみ許可
  describe 'DELETE #destroy' do
    describe '正常' do
      context 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it 'ユーザーを削除する' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.to change(Viewer, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to viewers_url(organization_id: organization.id)
        end
      end
    end

    describe '異常' do
      context '同組織オーナー' do
        before(:each) do
          current_user(user_owner)
        end

        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_url
        end
      end

      context '同組織スタッフ' do
        before(:each) do
          current_user(user_staff)
        end

        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_url
        end
      end

      context '他組織オーナー' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_url
        end
      end

      context '他組織スタッフ' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_url
        end
      end

      context '本人' do
        before(:each) do
          current_viewer(viewer)
        end

        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_url
        end
      end

      context '同組織他視聴者' do
        before(:each) do
          current_viewer(viewer1)
        end

        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_url
        end
      end

      context 'ログインなし' do
        it '削除できない' do
          expect {
            delete viewer_path(viewer), params: { id: viewer.id }
          }.not_to change(Viewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(viewer_path(viewer), params: { id: viewer.id })
          ).to redirect_to root_url
        end
      end
    end
  end
end
