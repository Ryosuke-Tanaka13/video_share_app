require 'rails_helper'

RSpec.describe 'LoginlessViewer', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }
  let(:loginless_viewer) { create(:loginless_viewer) }
  let(:loginless_viewer1) { create(:loginless_viewer1) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }
  let(:another_viewer) { create(:another_viewer, confirmed_at: Time.now) }
  let(:another_loginless_viewer) { create(:another_loginless_viewer) }

  let(:organization_viewer) { create(:organization_viewer) }
  let(:organization_viewer1) { create(:organization_viewer1) }

  let(:organization_loginless_viewer) { create(:organization_loginless_viewer) }
  let(:organization_loginless_viewer1) { create(:organization_loginless_viewer1) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    loginless_viewer
    loginless_viewer1
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    another_loginless_viewer
    organization_viewer
    organization_viewer1
    organization_loginless_viewer
    organization_loginless_viewer1
  end

  # システム管理者　投稿者　のみ許可
  describe 'GET #index' do
    describe '正常' do
      context 'システム管理者の場合（視聴者一覧）' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get loginless_viewers_path(organization_id: organization.id)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end

      context 'オーナーの場合（視聴者一覧）' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get loginless_viewers_path(organization_id: organization.id)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end

      context 'スタッフの場合（視聴者一覧）' do
        before(:each) do
          login_session(user_staff)
          current_user(user_staff)
          get loginless_viewers_path(organization_id: organization.id)
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
      describe '視聴者の場合（視聴者一覧）' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
          get loginless_viewers_path(organization_id: organization.id)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status ' 302'
          expect(response).to redirect_to root_path
        end
      end

      describe 'ログインなしの場合（視聴者一覧）' do
        before(:each) do
          get loginless_viewers_path(organization_id: organization.id)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status ' 302'
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  # 'GET #new' なし

  # 規制なし
  describe 'POST #create' do
    describe '正常' do
      it '組織とオーナーが新規作成される' do
        expect {
          post loginless_viewers_path,
            params: {
              loginless_viewer: {
                name:  'test',
                email: 'test@email.com'
              }
            }
        }.to change(LoginlessViewer, :count).by(1)
      end

      it 'トップ画面にリダイレクトされる' do
        expect(
          post(loginless_viewers_path,
            params: {
              loginless_viewer: {
                name:  'test',
                email: 'test@email.com'
              }
            }
          )
        ).to redirect_to root_path
      end
    end

    describe '異常' do
      it '入力が不十分だと新規作成されない' do
        expect {
          post loginless_viewers_path,
            params: {
              loginless_viewer: {
                name:  '',
                email: 'test@email.com'
              }
            }
        }.to change(LoginlessViewer, :count).by(0)
      end
    end
  end

  # システム管理者　set_loginless_viewerと同組織オーナー　のみ許可
  describe 'GET #show' do
    context '視聴者詳細' do
      describe '正常' do
        context 'システム管理者' do
          before(:each) do
            current_system_admin(system_admin)
            get loginless_viewer_path(loginless_viewer)
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
            get loginless_viewer_path(loginless_viewer)
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
        context '別組織のオーナー' do
          before(:each) do
            current_user(another_user_owner)
            get loginless_viewer_path(loginless_viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end

        context '同組織のスタッフ' do
          before(:each) do
            current_user(user_staff)
            get loginless_viewer_path(loginless_viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end

        context '別組織のスタッフ' do
          before(:each) do
            current_user(another_user_staff)
            get loginless_viewer_path(loginless_viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end

        context '同組織視聴者' do
          before(:each) do
            current_viewer(viewer)
            get loginless_viewer_path(loginless_viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end

        context '他組織視聴者' do
          before(:each) do
            current_viewer(another_viewer)
            get loginless_viewer_path(loginless_viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end

        context 'ログインなし' do
          before(:each) do
            get loginless_viewer_path(loginless_viewer)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end
  end

  # 'GET #edit' なし

  # 'PATCH #update' なし

  # システム管理者　のみ許可
  describe 'DELETE #destroy' do
    context '正常' do
      context 'システム管理者の場合' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it 'ユーザーを削除する' do
          expect {
            delete loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id }
          }.to change(LoginlessViewer, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id })
          ).to redirect_to organizations_path
        end
      end
    end

    context '異常' do
      context '同組織オーナーの場合' do
        before(:each) do
          current_user(user_owner)
        end

        it '削除できない' do
          expect {
            delete loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id }
          }.not_to change(LoginlessViewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id })
          ).to redirect_to root_path
        end
      end

      context '同組織スタッフの場合' do
        before(:each) do
          current_user(user_staff)
        end

        it '削除できない' do
          expect {
            delete loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id }
          }.not_to change(LoginlessViewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id })
          ).to redirect_to root_path
        end
      end

      context '他組織オーナーの場合' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '削除できない' do
          expect {
            delete loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id }
          }.not_to change(LoginlessViewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id })
          ).to redirect_to root_path
        end
      end

      context '他組織スタッフの場合' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '削除できない' do
          expect {
            delete loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id }
          }.not_to change(LoginlessViewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id })
          ).to redirect_to root_path
        end
      end

      context '同組織の他視聴者の場合' do
        before(:each) do
          current_viewer(viewer1)
        end

        it '削除できない' do
          expect {
            delete loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id }
          }.not_to change(LoginlessViewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id })
          ).to redirect_to root_path
        end
      end

      context 'ログインなしの場合' do
        it '削除できない' do
          expect {
            delete loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id }
          }.not_to change(LoginlessViewer, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(loginless_viewer_path(loginless_viewer), params: { id: loginless_viewer.id })
          ).to redirect_to root_path
        end
      end
    end
  end
end
