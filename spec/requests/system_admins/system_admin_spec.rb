require 'rails_helper'

RSpec.describe 'SystemAdmin', type: :request do
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

  # GET index なし

  # GET new なし

  # POST create なし

  # システム管理者　のみ許可
  describe 'GET #show' do
    context 'システム管理者詳細（権限）' do
      describe '正常' do
        context '本人' do
          before(:each) do
            current_system_admin(system_admin)
            get system_admin_path(system_admin)
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
        context 'オーナー' do
          before(:each) do
            current_user(user_owner)
            get system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end

        context 'スタッフ' do
          before(:each) do
            current_user(user_staff)
            get system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end

        context '視聴者' do
          before(:each) do
            current_viewer(viewer)
            get system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end

        context 'ログインなし' do
          before(:each) do
            get system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end
      end
    end
  end

  # システム管理者　のみ許可
  describe 'GET #edit' do
    context 'システム管理者編集（権限）' do
      describe '正常' do
        context '本人' do
          before(:each) do
            current_system_admin(system_admin)
            get edit_system_admin_path(system_admin)
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
        context 'オーナー' do
          before(:each) do
            current_user(user_owner)
            get edit_system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end

        context 'スタッフ' do
          before(:each) do
            current_user(user_staff)
            get edit_system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end

        context '動画視聴者' do
          before(:each) do
            current_viewer(viewer)
            get edit_system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end

        context 'ログインなし' do
          before(:each) do
            get edit_system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_url
          end
        end
      end
    end
  end

  # システム管理者　のみ許可
  describe 'PATCH #update' do
    context 'システム管理者更新' do
      describe '正常' do
        context '本人' do
          before(:each) do
            current_system_admin(system_admin)
          end

          it '本人はアップデートできる' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name:  'ユーザー',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { SystemAdmin.find(system_admin.id).name }.from(system_admin.name).to('ユーザー')
          end
        end
      end

      describe '異常' do
        context 'オーナー' do
          before(:each) do
            current_user(user_owner)
          end

          it 'オーナはアップデートできない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end
        end

        context 'スタッフ' do
          before(:each) do
            current_user(user_staff)
          end

          it 'スタッフはアップデートできない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name:  'system_admin',
                    email: 'system_admin@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end
        end

        context '視聴者' do
          before(:each) do
            current_viewer(viewer)
          end

          it '視聴者はアップデートできない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name:  'system_admin',
                    email: 'system_admin@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end
        end

        context 'ログインなし' do
          it 'ログインなしはアップデートできない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name:  'system_admin',
                    email: 'system_admin@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end
        end
      end
    end

    context 'システム管理者更新（動作）' do
      context '本人' do
        before(:each) do
          edit_system_admin_path(system_admin)
          current_system_admin(system_admin)
        end

        # emailの更新については認証が必要
        it '名前がアップデートされる' do
          expect {
            patch system_admin_path(system_admin),
              params: {
                system_admin: {
                  name:  'ユーザー',
                  email: 'sample@email.com'
                }
              }
          }.to change { SystemAdmin.find(system_admin.id).name }.from(system_admin.name).to('ユーザー')
        end

        it 'showにリダイレクトされる' do
          expect(
            patch(system_admin_path(system_admin),
              params: {
                system_admin: {
                  name: 'ユーザー'
                }
              })
          ).to redirect_to system_admin_path(system_admin)
        end

        describe '異常' do
          it '名前が空白でアップデートされない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name:  ' ',
                    email: 'sample@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end

          it 'email更新時、認証なしではアップデートされない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name:  'system_admin',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).email }
          end

          it '登録失敗するとエラーを出す' do
            expect(
              patch(system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name: ' '
                  }
                })
            ).to render_template :edit
          end
        end
      end
    end
  end

  # DELETE destroy　なし
end
