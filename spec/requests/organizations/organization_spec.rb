require 'rails_helper'

RSpec.describe 'Organization', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }

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
    video_sample
    another_organization
    another_user_owner
    another_user_staff
    another_viewer
    organization_viewer
    organization_viewer1
    organization_viewer2
    organization_viewer3
  end

  # システム管理者　のみ許可
  describe 'GET #index' do
    describe '正常' do
      context 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get organizations_path
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status :ok
        end
      end
    end

    describe '異常' do
      context 'オーナー' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get organizations_path
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context 'スタッフ' do
        before(:each) do
          login_session(user_staff)
          current_user(user_staff)
          get organizations_path
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '視聴者' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
          get organizations_path
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context 'ログインなし' do
        before(:each) do
          get organizations_path
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end
    end
  end

  # 規制なし
  describe 'GET #new' do
    context '組織作成' do
      describe '正常' do
        context 'システム管理者' do
          before(:each) do
            current_system_admin(system_admin)
            get new_organization_path
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end

        context 'オーナー' do
          before(:each) do
            current_user(user_owner)
            get new_organization_path
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end

        context 'スタッフ' do
          before(:each) do
            current_user(user_staff)
            get new_organization_path
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end

        context '視聴者' do
          before(:each) do
            current_viewer(viewer)
            get new_organization_path
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end

        context 'ログインなし' do
          before(:each) do
            get new_organization_path
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end
      end

      # 異常なし
    end
  end

  # 規制なし
  describe 'POST #create' do
    context '組織生成（動作）' do
      describe '正常' do
        before(:each) do
          new_organization_path
        end

        it '組織とオーナーが新規作成される' do
          expect {
            post organizations_path,
              params: {
                organization: {
                  name:  '組織1',
                  email: 'sample1@email.com',
                  users: {
                    name:                  'オーナー1',
                    email:                 'sample1@email.com',
                    password:              'password',
                    password_confirmation: 'password'
                  }
                }
              }
          }.to change(Organization, :count).by(1)
            .and change(User, :count).by(1)
        end

        it 'ログイン画面にリダイレクトされる' do
          expect(
            post(organizations_path,
              params: {
                organization: {
                  name:  '組織1',
                  email: 'sample1@email.com',
                  users: {
                    name:                  'オーナー1',
                    email:                 'sample1@email.com',
                    password:              'password',
                    password_confirmation: 'password'
                  }
                }
              }
            )
          ).to redirect_to user_session_path
        end
      end

      describe '異常' do
        before(:each) do
          new_organization_path
        end

        it '入力が不十分だと新規作成されない' do
          expect {
            post organizations_path,
              params: {
                organization: {
                  name:  ' ',
                  email: 'sample1@email.com',
                  users: {
                    name:                  'test',
                    email:                 'sample1@email.com',
                    password:              'password',
                    password_confirmation: 'password'
                  }
                }
              }
          }.not_to change(Organization, :count)
          expect {
            post organizations_path,
              params: {
                organization: {
                  name:  ' ',
                  email: 'sample1@email.com',
                  users: {
                    name:                  'test',
                    email:                 'sample1@email.com',
                    password:              'password',
                    password_confirmation: 'password'
                  }
                }
              }
          }.not_to change(User, :count)
        end

        it '登録失敗するとエラーを出す' do
          expect(
            post(organizations_path,
              params: {
                organization: {
                  name:  '',
                  email: '',
                  users: {
                    name:                  '',
                    email:                 '',
                    password:              '',
                    password_confirmation: ''
                  }
                }
              }
            )
          ).to render_template :new
        end
      end
    end

    describe '組織生成（権限）' do
      describe '正常' do
        context 'システム管理者' do
          before(:each) do
            current_system_admin(system_admin)
            new_organization_path
          end

          it '組織とオーナーが新規作成される' do
            expect {
              post organizations_path,
                params: {
                  organization: {
                    name:  '組織1',
                    email: 'sample1@email.com',
                    users: {
                      name:                  'オーナー1',
                      email:                 'sample1@email.com',
                      password:              'password',
                      password_confirmation: 'password'
                    }
                  }
                }
            }.to change(Organization, :count).by(1)
              .and change(User, :count).by(1)
          end
        end

        context 'オーナー' do
          before(:each) do
            current_user(user_owner)
            new_organization_path
          end

          it '組織とオーナーが新規作成される' do
            expect {
              post organizations_path,
                params: {
                  organization: {
                    name:  '組織1',
                    email: 'sample1@email.com',
                    users: {
                      name:                  'オーナー1',
                      email:                 'sample1@email.com',
                      password:              'password',
                      password_confirmation: 'password'
                    }
                  }
                }
            }.to change(Organization, :count).by(1)
              .and change(User, :count).by(1)
          end
        end

        context 'スタッフ' do
          before(:each) do
            current_user(user_staff)
            new_organization_path
          end

          it '組織とオーナーが新規作成される' do
            expect {
              post organizations_path,
                params: {
                  organization: {
                    name:  '組織1',
                    email: 'sample1@email.com',
                    users: {
                      name:                  'オーナー1',
                      email:                 'sample1@email.com',
                      password:              'password',
                      password_confirmation: 'password'
                    }
                  }
                }
            }.to change(Organization, :count).by(1)
              .and change(User, :count).by(1)
          end
        end

        context '視聴者' do
          before(:each) do
            current_viewer(viewer)
            new_organization_path
          end

          it '組織とオーナーが新規作成される' do
            expect {
              post organizations_path,
                params: {
                  organization: {
                    name:  '組織1',
                    email: 'sample1@email.com',
                    users: {
                      name:                  'オーナー1',
                      email:                 'sample1@email.com',
                      password:              'password',
                      password_confirmation: 'password'
                    }
                  }
                }
            }.to change(Organization, :count).by(1)
              .and change(User, :count).by(1)
          end
        end

        context 'ログインなし' do
          before(:each) do
            new_organization_path
          end

          it '組織とオーナーが新規作成される' do
            expect {
              post organizations_path,
                params: {
                  organization: {
                    name:  '組織1',
                    email: 'sample1@email.com',
                    users: {
                      name:                  'オーナー1',
                      email:                 'sample1@email.com',
                      password:              'password',
                      password_confirmation: 'password'
                    }
                  }
                }
            }.to change(Organization, :count).by(1)
              .and change(User, :count).by(1)
          end
        end
      end

      # 異常なし
    end
  end

  # システム管理者　set_userと同組織投稿者　のみ許可
  describe 'GET #show' do
    context '組織詳細(権限)' do
      describe '正常' do
        context 'システム管理者' do
          before(:each) do
            current_system_admin(system_admin)
            get organization_path(organization)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end

        context '所属オーナー' do
          before(:each) do
            current_user(user_owner)
            get organization_path(organization)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end

        context '所属スタッフ' do
          before(:each) do
            current_user(user_staff)
            get organization_path(organization)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end
      end

      describe '異常' do
        context '別組織のオーナー' do
          before(:each) do
            current_user(another_user_owner)
            get organization_path(organization)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end

        context '別組織のスタッフ' do
          before(:each) do
            current_user(another_user_staff)
            get organization_path(organization)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end

        context '動画視聴者' do
          before(:each) do
            current_viewer(viewer)
            get organization_path(organization)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end

        context 'ログインなし' do
          before(:each) do
            get organization_path(organization)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end
      end
    end
  end

  # システム管理者　set_organizationのオーナー　のみ許可
  describe 'GET #edit' do
    context '組織編集（権限）' do
      describe '正常' do
        context 'システム管理者' do
          before(:each) do
            current_system_admin(system_admin)
            get edit_user_path(user_owner)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end

        context '所属オーナー' do
          before(:each) do
            current_user(user_owner)
            get edit_user_path(user_owner)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status :ok
          end
        end
      end

      describe '異常' do
        context '同組織スタッフ' do
          before(:each) do
            current_user(user_staff)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end

        context '別組織オーナー' do
          before(:each) do
            current_user(another_user_owner)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end

        context '別組織スタッフ' do
          before(:each) do
            current_user(another_user_staff)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end

        context '動画視聴者場合' do
          before(:each) do
            current_viewer(viewer)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end

        context 'ログインなし場合' do
          before(:each) do
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status :found
            expect(response).to redirect_to root_url
          end
        end
      end
    end
  end

  # システム管理者　set_organizationのオーナー　のみ許可
  describe 'PATCH #update' do
    context '組織更新（権限）' do
      describe '正常' do
        context 'システム管理者' do
          before(:each) do
            current_system_admin(system_admin)
          end

          it 'アップデートできる' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'test',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { Organization.find(organization.id).name }.from(organization.name).to('test')
          end
        end

        context '所属オーナー' do
          before(:each) do
            current_user(user_owner)
          end

          it 'アップデートできる' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'test',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { Organization.find(organization.id).name }.from(organization.name).to('test')
          end
        end
      end

      describe '異常' do
        context '所属スタッフ' do
          before(:each) do
            current_user(user_staff)
          end

          it '所属スタッフはアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end

        context '別組織のオーナー' do
          before(:each) do
            current_user(another_user_owner)
          end

          it '別組織のオーナはアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end

        context '別組織のスタッフ' do
          before(:each) do
            current_user(another_user_staff)
          end

          it '別組織のスタッフはアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end

        context '視聴者' do
          before(:each) do
            current_viewer(viewer)
          end

          it '視聴者はアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end

        context 'ログインなし' do
          it 'ログインなしはアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end
      end
    end

    context '組織更新（動作）' do
      context '所属オーナー' do
        before(:each) do
          current_user(user_owner)
        end

        describe '正常' do
          it '名前とemailがアップデートされる' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  'test',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { Organization.find(organization.id).name }.from(organization.name).to('test')
              .and change { Organization.find(organization.id).email }.from(organization.email).to('test_spec@example.com')
          end

          it 'showにリダイレクトされる' do
            expect(
              patch(organization_path(organization),
                params: {
                  organization: {
                    name:  'test',
                    email: 'test_spec@example.com'
                  }
                })
            ).to redirect_to organization_path(organization)
          end
        end

        describe '異常' do
          it '名前が空白でアップデートされない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name:  '',
                    email: 'test_spec@example.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end

          it '登録失敗するとエラーを出す' do
            expect(
            patch(organization_path(organization),
              params: {
                organization: {
                  name:  '',
                  email: 'test_spec@example.com'
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

        it '組織を削除する' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.to change(Organization, :count).by(-1)
            .and change(Video, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(organization_path(organization), params: { id: organization.id })
          ).to redirect_to organizations_path
        end
      end
    end

    describe '異常' do
      context '所属オーナー' do
        before(:each) do
          current_user(user_owner)
        end

        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(organization_path(organization), params: { id: organization.id })
          ).to redirect_to root_url
        end
      end

      context '他組織のオーナー' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(organization_path(organization), params: { id: organization.id })
          ).to redirect_to root_url
        end
      end

      context '所属スタッフ' do
        before(:each) do
          current_user(user_staff)
        end

        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(organization_path(organization), params: { id: organization.id })
          ).to redirect_to root_url
        end
      end

      context '他組織のスタッフ' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(organization_path(organization), params: { id: organization.id })
          ).to redirect_to root_url
        end
      end

      context 'ログインなし' do
        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(organization_path(organization), params: { id: organization.id })
          ).to redirect_to root_url
        end
      end
    end
  end
end
