require 'rails_helper'

RSpec.describe 'User', type: :request do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }
  let(:user1) { create(:user1, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user) { create(:another_user, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_owner
    user
    user1
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
        get users_path(system_admin)
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
        get users_path(user_owner)
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
        get users_path(user)
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
        get users_path(viewer)
      end

      it 'アクセス権限なしのためリダイレクト' do
        expect(response).to have_http_status ' 302'
        expect(response).to redirect_to root_path
      end
    end

    describe '異常(ログインなし)' do
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
                name:  '組織1',
                email: 'sample1@email.com',
                users: {
                  name:                  ' ',
                  email:                 'sample1@email.com',
                  password:              'password',
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

  describe 'PATCH #update' do
    describe 'オーナー情報の編集' do
      describe '本人の場合（オーナー編集）' do
        before(:each) do
          current_user(user_owner)
        end

        describe '正常' do
          it '同組織のオーナはアップデートできる' do
            expect {
              patch user_path(user_owner),
                params: {
                  user: {
                    name:  'ユーザー',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { User.find(user_owner.id).name }.from(user_owner.name).to('ユーザー')
          end
        end
      end

      describe '別組織のオーナーの場合（オーナー編集）' do
        before(:each) do
          current_user(another_user_owner)
        end

        describe '異常' do
          it '別組織のオーナはアップデートできない' do
            expect {
              patch user_path(user_owner),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_owner.id).name }
          end
        end
      end

      describe 'スタッフの場合（オーナー編集）' do
        before(:each) do
          current_user(user)
        end

        describe '異常' do
          it '別組織のオーナはアップデートできない' do
            expect {
              patch user_path(user_owner),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_owner.id).name }
          end
        end
      end

      describe 'システム管理者の場合（オーナー編集）' do
        before(:each) do
          current_system_admin(system_admin)
        end

        describe '異常' do
          it 'アップデートできない' do
            expect {
              patch user_path(user_owner),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_owner.id).name }
          end
        end
      end

      describe '視聴者の場合（オーナー編集）' do
        before(:each) do
          current_viewer(viewer)
        end

        describe '異常' do
          it '視聴者はアップデートできない' do
            expect {
              patch user_path(user_owner),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_owner.id).name }
          end
        end
      end

      describe 'ログインなしの場合（オーナー編集）' do
        describe '異常' do
          it 'ログインなしはアップデートできない' do
            expect {
              patch user_path(user_owner),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_owner.id).name }
          end
        end
      end
    end

    describe 'スタッフ情報の編集' do
      describe '本人の場合（スタッフ編集）' do
        before(:each) do
          edit_user_path(user)
          current_user(user)
        end

        describe '正常' do
          # emailの更新については認証が必要
          it '名前がアップデートされる' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'ユーザー',
                    email: 'sample@email.com'
                  }
                }
            }.to change { User.find(user.id).name }.from(user.name).to('ユーザー')
          end

          it 'indexにリダイレクトされる' do
            expect(
              patch(user_path(user),
                params: {
                  user: {
                    name: 'ユーザー'
                  }
                })
            ).to redirect_to users_path
          end
        end

        describe '異常' do
          it '名前が空白でアップデートされない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  ' ',
                    email: 'sample@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end

          it 'email更新時、認証なしではアップデートされない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end

          it '登録失敗するとエラーを出す' do
            expect(
              patch(user_path(user),
                params: {
                  user: {
                    name: ' '
                  }
                })
            ).to render_template :edit
          end
        end
      end

      describe '同組織の他スタッフの場合（スタッフ編集）' do
        before(:each) do
          edit_user_path(user1)
          current_user(user1)
        end

        describe '異常' do
          it '同組織の他スタッフはアップデートできない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end
        end
      end

      describe '別組織のスタッフの場合（スタッフ編集）' do
        before(:each) do
          current_user(another_user)
        end

        describe '異常' do
          it '他のスタッフはアップデートできない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end
        end
      end

      describe '同組織のオーナーの場合（スタッフ編集）' do
        before(:each) do
          current_user(user_owner)
        end

        describe '正常' do
          it '同組織のオーナはアップデートできる' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'ユーザー',
                    email: 'sample@email.com'
                  }
                }
            }.to change { User.find(user.id).name }.from(user.name).to('ユーザー')
          end
        end
      end

      describe '別組織のオーナーの場合（スタッフ編集）' do
        before(:each) do
          current_user(another_user_owner)
        end

        describe '異常' do
          it '別組織のオーナはアップデートできない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end
        end
      end

      describe 'システム管理者の場合（スタッフ編集）' do
        before(:each) do
          current_system_admin(system_admin)
        end

        describe '異常' do
          it 'アップデートできない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end
        end
      end

      describe '視聴者の場合（スタッフ編集）' do
        before(:each) do
          current_viewer(viewer)
        end

        describe '異常' do
          it '視聴者はアップデートできない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end
        end
      end

      describe 'ログインなしの場合（スタッフ編集）' do
        describe '異常' do
          it 'ログインなしはアップデートできない' do
            expect {
              patch user_path(user),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user.id).name }
          end
        end
      end
    end
  end

  describe 'GET #show' do
    describe 'オーナー詳細' do
      describe 'システム管理者の場合（オーナー詳細）' do
        describe '正常' do
          before(:each) do
            current_system_admin(system_admin)
            get user_path(user_owner)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '本人の場合（オーナー詳細）' do
        describe '正常' do
          before(:each) do
            current_user(user_owner)
            get user_path(user_owner)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '同組織のスタッフの場合（オーナー詳細）' do
        describe '異常' do
          before(:each) do
            current_user(user)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe '別組織のオーナーの場合（オーナー詳細）' do
        describe '異常' do
          before(:each) do
            current_user(another_user_owner)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe '別組織のスタッフの場合（オーナー詳細）' do
        describe '異常' do
          before(:each) do
            current_user(another_user)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe '動画視聴者の場合（オーナー詳細）' do
        describe '異常' do
          before(:each) do
            current_viewer(viewer)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe 'ログインなしの場合（オーナー詳細）' do
        describe '異常' do
          before(:each) do
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end

    describe 'スタッフ詳細' do
      describe 'システム管理者の場合（スタッフ詳細）' do
        describe '正常' do
          before(:each) do
            current_system_admin(system_admin)
            get user_path(user)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '本人の場合（スタッフ詳細）' do
        describe '正常' do
          before(:each) do
            current_user(user)
            get user_path(user)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '同組織のオーナーの場合（スタッフ詳細）' do
        describe '正常' do
          before(:each) do
            current_user(user_owner)
            get user_path(user)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
      end

      describe '同組織の他スタッフの場合（スタッフ詳細）' do
        describe '異常' do
          before(:each) do
            current_user(user1)
            get user_path(user)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe '別組織のオーナーの場合（スタッフ詳細）' do
        describe '異常' do
          before(:each) do
            current_user(another_user_owner)
            get user_path(user)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe '別組織のスタッフの場合（スタッフ詳細）' do
        describe '異常' do
          before(:each) do
            current_user(another_user)
            get user_path(user)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe '動画視聴者の場合（スタッフ詳細）' do
        describe '異常' do
          before(:each) do
            current_viewer(viewer)
            get user_path(user)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end

      describe 'ログインなしの場合（スタッフ詳細）' do
        describe '異常' do
          before(:each) do
            get user_path(user)
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
    describe 'システム管理者の場合（スタッフ削除）' do
      before(:each) do
        current_system_admin(system_admin)
      end

      describe '正常' do
        it 'ユーザーを削除する' do
          expect {
            delete user_path(user), params: { id: user.id }
          }.to change(User, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(user_path(user), params: { id: user.id })
          ).to redirect_to users_path
        end
      end
    end

    describe '自組織のオーナーの場合（スタッフ削除）' do
      before(:each) do
        current_user(user_owner)
      end

      describe '正常' do
        it 'ユーザーを論理削除する' do
          expect {
            delete user_path(user), params: { id: user.id }
          }.to change { User.find(user.id).is_valid }.from(user.is_valid).to(false)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(user_path(user), params: { id: user.id })
          ).to redirect_to users_path
        end
      end
    end

    describe '他組織のオーナーの場合（スタッフ削除）' do
      before(:each) do
        current_user(another_user_owner)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete user_path(user), params: { id: user.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user), params: { id: user.id })
          ).to redirect_to root_path
        end
      end
    end

    describe '本人の場合（スタッフ削除）' do
      before(:each) do
        current_user(user)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete user_path(user), params: { id: user.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user), params: { id: user.id })
          ).to redirect_to root_path
        end
      end
    end

    describe '同組織の他スタッフの場合（スタッフ削除）' do
      before(:each) do
        current_user(user1)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete user_path(user), params: { id: user.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user), params: { id: user.id })
          ).to redirect_to root_path
        end
      end
    end

    describe '他組織のスタッフの場合（スタッフ削除）' do
      before(:each) do
        current_user(another_user)
      end

      describe '異常' do
        it '削除できない' do
          expect {
            delete user_path(user), params: { id: user.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user), params: { id: user.id })
          ).to redirect_to root_path
        end
      end
    end

    describe 'ログインなしの場合（スタッフ削除）' do
      describe '異常' do
        it '削除できない' do
          expect {
            delete user_path(user), params: { id: user.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user), params: { id: user.id })
          ).to redirect_to root_path
        end
      end
    end
  end
end
