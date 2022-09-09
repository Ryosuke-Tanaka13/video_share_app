require 'rails_helper'

RSpec.describe 'User', type: :request do
  # let!(:user) { FactoryBot.create(:user, password: 'password', confirmed_at: Time.now) }
  let(:organization) { create(:organization) }
  let(:another_organization) { create(:another_organization) }
  let(:user_owner) { create(:user_owner, name: 'owner1', organization_id: organization.id) }
  let(:another_user_owner) { create(:another_user_owner, name: 'owner2', organization_id: another_organization.id) }
  let(:user) { create(:user, name: 'user', email: 'sample@email.com', password: 'password', organization_id: organization.id, confirmed_at: Time.now) }
  # let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  # let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }

  before(:each) do
    organization
    another_organization
    user_owner
    another_user_owner
    user
    # folder_celeb
    # folder_tech
  end

  # describe '管理者がログインできることを確認' do
  #   it do
  #     get new_user_session_path
  #     expect(response).to have_http_status(:success)
  #     post user_session_path, params: { user: { email: user.email, password: user.password } }
  #     expect(response).to have_http_status(:found)
  #     expect(response).to redirect_to 'http://www.example.com/users'
  #   end
  # end

  describe 'GET #index' do
    describe '正常(オーナー)' do
      before(:each) do
        login_session(user_owner)
        current_user(user_owner)
        get users_path(user_owner)
      end

      it 'レスポンスに成功する' do
        expect(response).to be_successful
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '正常(投稿者)' do
      before(:each) do
        login_session(user)
        current_user(user)
        get users_path(user)
      end

      it 'レスポンスに成功する' do
        expect(response).to be_successful
      end

      it '正常値レスポンス' do
        expect(response).to have_http_status '200'
      end
    end

    describe '異常' do
      before(:each) do
        get users_path
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
        new_organization_path
      end

      it '組織とオーナーが新規作成される' do
        expect {
          post organizations_path,
            params: {
              organization: {
                name: '組織1',
                email: 'sample1@email.com',
                users: {
                  name: 'オーナー1',
                  email: 'sample1@email.com',
                  password: 'password',
                  password_confirmation: 'password'
                }
              }
            }
        }.to change(Organization, :count).by(1)
        .and change(User, :count).by(1)
      end

      it 'sign_inにリダイレクトされる' do
        expect(
          post(organizations_path,
            params: {
              organization: {
                name: '組織1',
                email: 'sample1@email.com',
                users: {
                  name: 'オーナー1',
                  email: 'sample1@email.com',
                  password: 'password',
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

      it '名前が空白だと新規作成されない' do
        expect {
          post organizations_path,
            params: {
              organization: {
                name: '組織1',
                email: 'sample1@email.com',
                users: {
                  name: ' ',
                  email: 'sample1@email.com',
                  password: 'password',
                  password_confirmation: 'password'
                }
              }
            }
        }.to change(Organization, :count).by(0)
        .and change(User, :count).by(0)
      end

      it '名前が重複していると新規作成されない' do
        expect {
          post organizations_path,
            params: {
              organization: {
                name: '組織1',
                email: 'sample1@email.com',
                users: {
                  name: 'user',
                  email: 'sample1@email.com',
                  password: 'password',
                  password_confirmation: 'password'
                }
              }
            }
        }.to change(Organization, :count).by(0)
        .and change(User, :count).by(0)
      end

      it '登録失敗するとエラーを出す' do
        expect(
          post(organizations_path,
            params: {
              organization: {
                name: '',
                email: '',
                users: {
                  name: '',
                  email: '',
                  password: '',
                  password_confirmation: ''
                }
              }
            }
          )
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
