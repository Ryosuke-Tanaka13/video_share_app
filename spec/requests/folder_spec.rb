require 'rails_helper'

RSpec.describe 'Organizations::Folders', type: :request do
  let(:organization) { create(:organization) }
  let(:another_organization) { create(:another_organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }

  before(:each) do
    organization
    another_organization
    user_owner
    another_user_owner
    user
    folder_celeb
    folder_tech
  end

  describe 'GET #index' do
    describe '正常' do
      before(:each) do
        login_session(user_owner)
        current_user(user_owner)
        get folders_path(user_owner)
      end

      it 'レスポンスに成功する' do
        expect(response).to be_successful
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end

      describe '異常' do
        before(:each) do
          login_session(user)
          current_user(user)
          get folders_path(user)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status ' 302'
          expect(response).to redirect_to users_path
        end
      end
    end
  end

  describe 'POST #create' do
    describe '正常' do
      before(:each) do
        current_user(user_owner)
      end

      it 'フォルダが新規作成される' do
        expect {
          post folders_path,
            params: {
              folder: {
                name: 'セレブ'
              }
            }
        }.to change(Folder, :count).by(1)
      end

      it 'indexにリダイレクトされる' do
        expect(
          post(folders_path,
            params: {
              folder: {
                name: 'セレブ'
              }
            })
        ).to redirect_to folders_path
      end
    end

    describe '異常' do
      before(:each) do
        current_user(user_owner)
      end

      it '名前が空白だと新規作成されない' do
        expect {
          post folders_path,
            params: {
              folder: {
                name: ''
              }, format: :js
            }
        }.not_to change(Folder, :count)
      end

      it '名前が重複していると新規作成されない' do
        expect {
          post folders_path,
            params: {
              folder: {
                name: 'セレブエンジニア'
              }, format: :js
            }
        }.not_to change(Folder, :count)
      end

      it '登録失敗するとモーダル上でエラーを出す' do
        expect(
          post(folders_path,
            params: {
              folder: {
                name: ''
              }, format: :js
            })
        ).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    describe 'フォルダ作成者が現在のログインユーザ' do
      before(:each) do
        current_user(user_owner)
      end

      describe '正常' do
        it 'フォルダ名がアップデートされる' do
          expect {
            patch folder_path(folder_celeb),
              params: {
                folder: {
                  name: 'セレブ'
                }
              }
          }.to change { Folder.find(folder_celeb.id).name }.from(folder_celeb.name).to('セレブ')
        end

        it 'indexにリダイレクトされる' do
          expect(
            patch(folder_path(folder_celeb),
              params: {
                folder: {
                  name: 'セレブ'
                }
              })
          ).to redirect_to folders_path
        end
      end

      describe '異常' do
        it 'フォルダ名が空白でアップデートされない' do
          expect {
            patch folder_path(folder_celeb),
              params: {
                folder: {
                  name: ''
                }
              }
          }.not_to change { Folder.find(folder_celeb.id).name }
        end

        it 'フォルダ名が重複してアップデートされない' do
          expect {
            patch folder_path(folder_tech),
              params: {
                folder: {
                  name: 'セレブエンジニア'
                }
              }
          }.not_to change { Folder.find(folder_celeb.id).name }
        end

        it 'indexにリダイレクトされる' do
          expect(
            patch(folder_path(folder_celeb),
              params: {
                folder: {
                  name: ''
                }
              })
          ).to redirect_to folders_path
        end
      end
    end

    describe 'フォルダ作成者以外の別組織オーナが現在のログインユーザ' do
      before(:each) do
        current_user(another_user_owner)
      end

      describe '異常' do
        it '別組織のオーナはアップデートできない' do
          expect {
            patch folder_path(folder_celeb),
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
    describe 'フォルダ作成者が現在のログインユーザ' do
      before(:each) do
        current_user(user_owner)
      end

      describe '正常' do
        it 'フォルダを削除する' do
          expect {
            delete folder_path(folder_celeb), params: { id: folder_celeb.id }
          }.to change(Folder, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(folder_path(folder_celeb), params: { id: folder_celeb.id })
          ).to redirect_to folders_path
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
            delete folder_path(folder_celeb), params: { id: folder_celeb.id }
          }.not_to change(Folder, :count)
        end
      end
    end
  end
end
