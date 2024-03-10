require 'rails_helper'

RSpec.xdescribe 'Organizations::Folders', type: :request do
  let(:organization) { create(:organization) }
  let(:another_organization) { create(:another_organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id) }
  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }
  let(:viewer) { create(:viewer) }

  before(:each) do
    organization
    another_organization
    system_admin
    user_owner
    another_user_owner
    user_staff
    folder_celeb
    folder_tech
    viewer
  end

  describe 'GET #index' do
    describe '正常' do
      describe '組織管理者' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get organization_folders_path(organization_id: organization.id)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status :ok
        end
      end

      describe '動画投稿者' do
        before(:each) do
          login_session(user_staff)
          current_user(user_staff)
          get organization_folders_path(organization_id: organization.id)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status :ok
        end
      end

      describe 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get organization_folders_path(organization_id: organization.id)
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
      describe '視聴者' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
          get organization_folders_path(organization_id: organization.id)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      describe '別組織の組織管理者' do
        before(:each) do
          login_session(another_user_owner)
          current_viewer(another_user_owner)
          get organization_folders_path(organization_id: organization.id)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end
    end
  end

  describe 'POST #create' do
    describe '正常' do
      describe '組織管理者' do
        before(:each) do
          current_user(user_owner)
        end

        it 'フォルダが新規作成される' do
          expect {
            post organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.to change(Folder, :count).by(1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            post(organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              })
          ).to redirect_to organization_folders_url(organization_id: organization.id)
        end
      end

      describe '動画投稿者' do
        before(:each) do
          current_user(user_staff)
        end

        it 'フォルダが新規作成される' do
          expect {
            post organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.to change(Folder, :count).by(1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            post(organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              })
          ).to redirect_to organization_folders_url(organization_id: organization.id)
        end
      end
    end

    describe '異常' do
      describe 'オーナ' do
        before(:each) do
          current_user(user_owner)
        end

        it '名前が空白だと新規作成されない' do
          expect {
            post organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: ''
                }, format: :js
              }
          }.not_to change(Folder, :count)
        end

        it '名前が重複していると新規作成されない' do
          expect {
            post organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: 'セレブエンジニア'
                }, format: :js
              }
          }.not_to change(Folder, :count)
        end

        it '登録失敗するとモーダル上でエラーを出す' do
          expect(
            post(organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: ''
                }, format: :js
              })
          ).to render_template :new
        end
      end

      describe 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it 'フォルダが新規作成されない' do
          expect {
            post organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.not_to change(Folder, :count)
        end
      end

      describe '視聴者' do
        before(:each) do
          current_viewer(viewer)
        end

        it 'フォルダが新規作成されない' do
          expect {
            post organization_folders_path(organization_id: organization.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.not_to change(Folder, :count)
        end
      end
    end
  end

  # フォルダ選択機能の実装の際にここから追記
  describe 'GET #show' do
    describe '正常' do
      describe '組織管理者' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get organization_folder_path(organization, folder_celeb)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status :ok
        end
      end

      describe '動画投稿者' do
        before(:each) do
          login_session(user_staff)
          current_user(user_staff)
          get organization_folder_path(organization, folder_celeb)
        end

        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end

        it '正常値レスポンス' do
          expect(response).to have_http_status :ok
        end
      end

      describe 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get organization_folder_path(organization, folder_celeb)
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
      describe '別組織の組織管理者' do
        before(:each) do
          login_session(another_user_owner)
          current_user(another_user_owner)
          get organization_folder_path(folder_celeb, organization_id: organization.id)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      describe '視聴者' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
          get organization_folder_path(organization, folder_celeb)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end
    end
  end
  # ここまで追記

  describe 'PATCH #update' do
    describe 'オーナ' do
      before(:each) do
        current_user(user_owner)
      end

      describe '正常' do
        it 'フォルダ名がアップデートされる' do
          expect {
            patch organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.to change { Folder.find(folder_celeb.id).name }.from(folder_celeb.name).to('セレブ')
        end

        it 'indexにリダイレクトされる' do
          expect(
            patch(organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              })
          ).to redirect_to organization_folders_url(organization_id: organization.id)
        end
      end

      describe '異常' do
        it 'フォルダ名が空白でアップデートされない' do
          expect {
            patch organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: ''
                }
              }
          }.not_to change { Folder.find(folder_celeb.id).name }
        end

        it 'フォルダ名が重複してアップデートされない' do
          expect {
            patch organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: 'セレブエンジニア'
                }
              }
          }.not_to change { Folder.find(folder_celeb.id).name }
        end

        it 'indexにリダイレクトされる' do
          expect(
            patch(organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: ''
                }
              })
          ).to redirect_to organization_folders_url(organization_id: organization.id)
        end
      end
    end

    describe '動画投稿者' do
      before(:each) do
        current_user(user_staff)
      end

      it 'フォルダ名がアップデートされる' do
        expect {
          patch organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
            params: {
              folder: {
                name: 'セレブ'
              }
            }
        }.to change { Folder.find(folder_celeb.id).name }.from(folder_celeb.name).to('セレブ')
      end
    end

    describe '別組織のオーナ' do
      before(:each) do
        current_user(another_user_owner)
      end

      describe '異常' do
        it '別組織のオーナはアップデートできない' do
          expect {
            patch organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.not_to change { Folder.find(folder_celeb.id).name }
        end
      end
    end

    describe 'システム管理者' do
      before(:each) do
        current_system_admin(system_admin)
      end

      describe '正常' do
        it 'フォルダ名がアップデートされる' do
          expect {
            patch organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.to change { Folder.find(folder_celeb.id).name }.from(folder_celeb.name).to('セレブ')
        end

        it 'indexにリダイレクトされる' do
          expect(
            patch(organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              })
          ).to redirect_to organization_folders_url(organization_id: organization.id)
        end
      end
    end

    describe '視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      describe '異常' do
        it '視聴者はアップデートできない' do
          expect {
            patch organization_folder_path(organization_id: organization.id, id: folder_celeb.id),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.not_to change { Folder.find(folder_celeb.id).name }
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    describe 'オーナ' do
      before(:each) do
        current_user(user_owner)
      end

      describe '正常' do
        it 'フォルダを削除する' do
          expect {
            delete organization_folder_path(organization_id: organization.id, id: folder_celeb.id), params: { id: folder_celeb.id }
          }.to change(Folder, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(organization_folder_path(organization_id: organization.id, id: folder_celeb.id), params: { id: folder_celeb.id })
          ).to redirect_to organization_folders_url(organization_id: organization.id)
        end
      end
    end

    describe 'フォルダ作成者以外の別組織オーナが現在のログインユーザ' do
      before(:each) do
        current_user(another_user_owner)
      end

      describe '異常' do
        it '別組織のオーナは削除できない' do
          expect {
            delete organization_folder_path(organization_id: organization.id, id: folder_celeb.id), params: { id: folder_celeb.id }
          }.not_to change(Folder, :count)
        end
      end
    end

    describe '動画投稿者' do
      before(:each) do
        current_user(user_staff)
      end

      describe '異常' do
        it '動画投稿者は削除できない' do
          expect {
            delete organization_folder_path(organization_id: organization.id, id: folder_celeb.id), params: { id: folder_celeb.id }
          }.not_to change(Folder, :count)
        end
      end
    end

    describe '視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      describe '異常' do
        it '視聴者は削除できない' do
          expect {
            delete organization_folder_path(organization_id: organization.id, id: folder_celeb.id), params: { id: folder_celeb.id }
          }.not_to change(Folder, :count)
        end
      end
    end

    describe 'システム管理者' do
      before(:each) do
        current_system_admin(system_admin)
      end

      describe '正常' do
        it 'フォルダを削除する' do
          expect {
            delete organization_folder_path(organization_id: organization.id, id: folder_celeb.id), params: { id: folder_celeb.id }
          }.to change(Folder, :count).by(-1)
        end
      end
    end
  end
end
