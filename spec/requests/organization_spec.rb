require 'rails_helper'

RSpec.describe 'Organization', type: :request do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user) { create(:another_user, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  

  before(:each) do
    organization
    user_owner
    user
    another_organization
    another_user_owner
    another_user
    system_admin
    viewer
  end

  describe 'GET #index' do
    describe '正常(システム管理者)' do
      before(:each) do
        login_session(system_admin)
        current_system_admin(system_admin)
        get organizations_path
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
        get organizations_path
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end

    describe '正常(スタッフ)' do
      before(:each) do
        login_session(user)
        current_user(user)
        get organizations_path
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end

    describe '異常(viewer)' do
      before(:each) do
        login_session(viewer)
        current_viewer(viewer)
        get organizations_path
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end

    describe '異常(ログインなし)' do
      before(:each) do
        get organizations_path
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

      it 'ログイン画面にリダイレクトされる' do
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

      it '入力が不十分だと新規作成されない' do
        expect {
          post organizations_path,
            params: {
              organization: {
                name: ' ',
                email: 'sample1@email.com',
                users: {
                  name: 'test',
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
    describe '組織情報の編集' do
      describe '所属オーナーの場合' do
        before(:each) do
          current_user(user_owner)
        end
  
        describe '正常' do
          it '同組織のオーナはアップデートできる' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name: 'ユーザー',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { Organization.find(organization.id).name }.from(organization.name).to('ユーザー')
          end
        end
      end
    
      describe '別組織のオーナーの場合' do
        before(:each) do
          current_user(another_user_owner)
        end
  
        describe '異常' do
          it '別組織のオーナはアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end
      end

      describe '所属スタッフの場合' do
        before(:each) do
          current_user(user)
        end
  
        describe '異常' do
          it '所属スタッフはアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end
      end

      describe 'システム管理者の場合' do
        before(:each) do
          current_system_admin(system_admin)
        end
  
        describe '異常' do
          it 'システム管理者はアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end
      end

      describe '視聴者の場合' do
        before(:each) do
          current_viewer(viewer)
        end
  
        describe '異常' do
          it '視聴者はアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end
      end

      describe 'ログインなしの場合' do
        describe '異常' do
          it 'ログインなしはアップデートできない' do
            expect {
              patch organization_path(organization),
                params: {
                  organization: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { Organization.find(organization.id).name }
          end
        end
      end
    end
  end

  describe 'GET #show' do
    describe '組織詳細' do
      describe 'システム管理者の場合' do
        describe '正常' do
          before(:each) do
            current_system_admin(system_admin)
            get organization_path(organization)
          end
    
          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end
    
          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end
      
      describe '所属オーナーの場合' do
        describe '正常' do
          before(:each) do
            current_user(user_owner)
            get organization_path(organization)
          end
    
          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end
    
          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '所属スタッフの場合' do
        describe '正常' do
          before(:each) do
            current_user(user)
            get organization_path(organization)
          end
    
          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end
    
          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '別組織のオーナーの場合' do
        describe '異常' do
          before(:each) do
            current_user(another_user_owner)
            get organization_path(organization)
          end
    
          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end
      
      describe '別組織のスタッフの場合' do
        describe '異常' do
          before(:each) do
            current_user(another_user)
            get organization_path(organization)
          end
    
          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe '動画視聴者の場合' do
        describe '異常' do
          before(:each) do
            current_viewer(viewer)
            get organization_path(organization)
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
            get organization_path(organization)
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
        it '組織を削除する' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.to change(Organization, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete organization_path(organization), params: { id: organization.id }
          ).to redirect_to organizations_path
        end
      end
    end

    describe '所属オーナーの場合' do
      before(:each) do
        current_user(user_owner)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete organization_path(organization), params: { id: organization.id }
          ).to redirect_to root_path
        end
      end
    end

    describe '他組織のオーナーの場合' do
      before(:each) do
        current_user(another_user_owner)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete organization_path(organization), params: { id: organization.id }
          ).to redirect_to root_path
        end
      end
    end

    describe '所属スタッフの場合' do
      before(:each) do
        current_user(user)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete organization_path(organization), params: { id: organization.id }
          ).to redirect_to root_path
        end
      end
    end

    describe '他組織のスタッフの場合' do
      before(:each) do
        current_user(another_user)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete organization_path(organization), params: { id: organization.id }
          ).to redirect_to root_path
        end
      end
    end

    describe 'ログインなしの場合' do
      describe '異常' do
        it '削除できない' do
          expect {
            delete organization_path(organization), params: { id: organization.id }
          }.not_to change(Organization, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete organization_path(organization), params: { id: organization.id }
          ).to redirect_to root_path
        end
      end
    end
  end
end
