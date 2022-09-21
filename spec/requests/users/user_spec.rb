require 'rails_helper'

RSpec.describe 'User', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_staff1) { create(:user_staff1, confirmed_at: Time.now) }
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
      describe 'システム管理者の場合（投稿者一覧）' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get users_path(organization_id: organization.id)
        end
  
        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end
  
        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end
  
      describe 'オーナーの場合（投稿者一覧）' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get users_path(organization_id: organization.id)
        end
  
        it 'レスポンスに成功する' do
          expect(response).to be_successful
        end
  
        it '正常値レスポンス' do
          expect(response).to have_http_status '200'
        end
      end
  
      describe 'スタッフの場合（投稿者一覧）' do
        before(:each) do
          login_session(user_staff)
          current_user(user_staff)
          get users_path(organization_id: organization.id)
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
      describe '視聴者の場合（投稿者一覧）' do
        before(:each) do
          login_session(viewer)
          current_viewer(viewer)
          get users_path(organization_id: organization.id)
        end
  
        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status ' 302'
          expect(response).to redirect_to root_path
        end
      end
  
      describe 'ログインなしの場合（投稿者一覧）' do
        before(:each) do
          get users_path(organization_id: organization.id)
        end
  
        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status ' 302'
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  # オーナー　のみ許可
  describe 'GET #new' do
    # オーナー作成は組織と同時生成の為、organization_spec.rbに記載
    # スタッフ作成のみ記載

    describe 'スタッフ作成' do
      describe '正常' do
        describe '同組織のオーナーの場合（スタッフ作成）' do
          before(:each) do
            current_user(user_owner)
            get new_user_path
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end

        describe '別組織のオーナーの場合（スタッフ作成）' do
          before(:each) do
            current_user(another_user_owner)
            get new_user_path
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
        describe '本人の場合（スタッフ作成）' do
          before(:each) do
            current_user(user_staff)
            get new_user_path
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to users_path
          end
        end

        describe 'システム管理者の場合（スタッフ作成）' do
          before(:each) do
            current_system_admin(system_admin)
            get new_user_path
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to users_path
          end
        end
  
        describe '同組織の他スタッフの場合（スタッフ作成）' do
          before(:each) do
            current_user(user_staff)
            get new_user_path
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to users_path
          end
        end
  
        describe '別組織のスタッフの場合（スタッフ作成）' do
          before(:each) do
            current_user(another_user_staff)
            get new_user_path
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to users_path
          end
        end
  
        describe '動画視聴者の場合（スタッフ作成）' do
          before(:each) do
            current_viewer(viewer)
            get new_user_path
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to users_path
          end
        end
  
        describe 'ログインなしの場合（スタッフ作成）' do
          before(:each) do
            get new_user_path
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end
  end
  
  # オーナー　のみ許可
  describe 'POST #create' do
    # オーナー作成は組織と同時生成の為、organization_spec.rbに記載 
    # スタッフ作成のみ記載
    describe '正常' do
      before(:each) do
        current_user(user_owner)
        new_user_path
      end

      it '組織とオーナーが新規作成される' do
        expect {
          post users_path,
            params: {
              user: {
                name:                  'staff',
                email:                 'staff@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
        }.to change(User, :count).by(1)
      end

      it 'トップ画面にリダイレクトされる' do
        expect(
          post(users_path,
          params: {
            user: {
              name:                  'staff',
              email:                 'staff@email.com',
              password:              'password',
              password_confirmation: 'password'
            }
          }
          )
        ).to redirect_to root_path
      end
    end

    describe '異常' do
      before(:each) do
        current_user(user_owner)
        new_user_path
      end

      it '入力が不十分だと新規作成されない' do
        expect {
          post users_path,
            params: {
              user: {
                name:                  '',
                email:                 'staff@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
        }.to change(User, :count).by(0)
      end

      it '登録失敗するとエラーを出す' do
        expect(
          post(users_path,
          params: {
            user: {
              name:                  '',
              email:                 'staff@email.com',
              password:              'password',
              password_confirmation: 'password'
            }
          }
          )
        ).to render_template :new
      end
    end
  end

  # システム管理者　set_userと同組織オーナー　投稿者本人 のみ許可
  describe 'GET #show' do
    describe 'オーナー詳細' do
      describe '正常' do
        describe 'システム管理者の場合' do
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
  
        describe '本人の場合' do
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
      
      describe '異常' do
        describe '別組織のオーナーの場合' do
          before(:each) do
            current_user(another_user_owner)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '同組織のスタッフの場合' do
          before(:each) do
            current_user(user_staff)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '別組織のスタッフの場合' do
          before(:each) do
            current_user(another_user_staff)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '動画視聴者の場合' do
          before(:each) do
            current_viewer(viewer)
            get user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end

        describe 'ログインなしの場合' do
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
      describe '正常' do
        describe 'システム管理者の場合' do
          before(:each) do
            current_system_admin(system_admin)
            get user_path(user_staff)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end

        describe '同組織のオーナーの場合' do
          before(:each) do
            current_user(user_owner)
            get user_path(user_staff)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end
  
        describe '本人の場合' do
          before(:each) do
            current_user(user_staff)
            get user_path(user_staff)
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
        describe '同組織の他スタッフの場合' do
          before(:each) do
            current_user(user_staff1)
            get user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '別組織のオーナーの場合' do
          before(:each) do
            current_user(another_user_owner)
            get user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '別組織のスタッフの場合' do
          before(:each) do
            current_user(another_user_staff)
            get user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '動画視聴者の場合' do
          before(:each) do
            current_viewer(viewer)
            get user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe 'ログインなしの場合' do
          before(:each) do
            get user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end
  end

  # 同組織オーナー　投稿者本人　のみ許可
  describe 'GET #edit' do
    describe 'オーナー編集' do
      describe '正常' do
        describe '本人の場合（オーナー編集）' do
          before(:each) do
            current_user(user_owner)
            get edit_user_path(user_owner)
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
        describe 'システム管理者の場合' do
          before(:each) do
            current_system_admin(system_admin)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '同組織のスタッフの場合（オーナー編集）' do
          before(:each) do
            current_user(user_staff)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '別組織のオーナーの場合（オーナー編集）' do
          before(:each) do
            current_user(another_user_owner)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '別組織のスタッフの場合（オーナー編集）' do
          before(:each) do
            current_user(another_user_staff)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end

        describe '動画視聴者の場合（オーナー編集）' do
          before(:each) do
            current_viewer(viewer)
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe 'ログインなしの場合（オーナー編集）' do
          before(:each) do
            get edit_user_path(user_owner)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end

    describe 'スタッフ編集' do
      describe '正常' do
        describe '同組織のオーナーの場合（スタッフ編集）' do
          before(:each) do
            current_user(user_owner)
            get edit_user_path(user_staff)
          end

          it 'レスポンスに成功する' do
            expect(response).to have_http_status(:success)
          end

          it '正常値レスポンス' do
            expect(response).to have_http_status '200'
          end
        end

        describe '本人の場合（スタッフ編集）' do
          before(:each) do
            current_user(user_staff)
            get edit_user_path(user_staff)
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
        describe 'システム管理者の場合（スタッフ編集）' do
          before(:each) do
            current_system_admin(system_admin)
            get edit_user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '同組織の他スタッフの場合（スタッフ編集）' do
          before(:each) do
            current_user(user_staff1)
            get edit_user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '別組織のオーナーの場合（スタッフ編集）' do
          before(:each) do
            current_user(another_user_owner)
            get edit_user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '別組織のスタッフの場合（スタッフ編集）' do
          before(:each) do
            current_user(another_user_staff)
            get edit_user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe '動画視聴者の場合（スタッフ編集）' do
          before(:each) do
            current_viewer(viewer)
            get edit_user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
  
        describe 'ログインなしの場合（スタッフ編集）' do
          before(:each) do
            get edit_user_path(user_staff)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status '302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end
  end
  
  # 同組織オーナー　投稿者本人　のみ許可
  describe 'PATCH #update' do
    describe 'オーナー更新' do
      describe '正常' do
        describe '本人の場合（オーナー編集）' do
          before(:each) do
            current_user(user_owner)
          end

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

      describe '異常' do
        describe '別組織のオーナーの場合（オーナー編集）' do
          before(:each) do
            current_user(another_user_owner)
          end
  
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
  
        describe 'スタッフの場合（オーナー編集）' do
          before(:each) do
            current_user(user_staff)
          end
  
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
  
        describe 'システム管理者の場合（オーナー編集）' do
          before(:each) do
            current_system_admin(system_admin)
          end
  
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
  
        describe '視聴者の場合（オーナー編集）' do
          before(:each) do
            current_viewer(viewer)
          end
  
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
  
        describe 'ログインなしの場合（オーナー編集）' do
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

    describe 'スタッフ更新（権限チェック）' do
      describe '正常' do
        describe '同組織のオーナーの場合' do
          before(:each) do
            current_user(user_owner)
          end
  
          it '同組織のオーナはアップデートできる' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'ユーザー',
                    email: 'sample@email.com'
                  }
                }
            }.to change { User.find(user_staff.id).name }.from(user_staff.name).to('ユーザー')
          end
        end

        describe '本人の場合' do
          before(:each) do
            edit_user_path(user_staff)
            current_user(user_staff)
          end
  
          # emailの更新については認証が必要
          it '本人はアップデートできる' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'ユーザー',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { User.find(user_staff.id).name }.from(user_staff.name).to('ユーザー')
          end
        end
      end
  
      describe '異常' do
        describe '同組織の他スタッフの場合' do
          before(:each) do
            current_user(user_staff1)
            edit_user_path(user_staff)
          end
  
          it '同組織の他スタッフはアップデートできない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).name }
          end
        end
  
        describe '別組織のスタッフの場合' do
          before(:each) do
            current_user(another_user_staff)
          end
  
          it '他のスタッフはアップデートできない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).name }
          end
        end

        describe '別組織のオーナーの場合' do
          before(:each) do
            current_user(another_user_owner)
          end
  
          it '別組織のオーナはアップデートできない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).name }
          end
        end
  
        describe 'システム管理者の場合' do
          before(:each) do
            current_system_admin(system_admin)
          end
  
          it 'アップデートできない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).name }
          end
        end
  
        describe '視聴者の場合' do
          before(:each) do
            current_viewer(viewer)
          end
  
          it '視聴者はアップデートできない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).name }
          end
        end
  
        describe 'ログインなしの場合' do
          it 'ログインなしはアップデートできない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).name }
          end
        end
      end
    end

    describe '投稿者更新（動作チェック）' do
      describe '本人の場合' do
        before(:each) do
          edit_user_path(user_staff)
          current_user(user_staff)
        end

        # emailの更新については認証が必要
        it '名前がアップデートされる' do
          expect {
            patch user_path(user_staff),
              params: {
                user: {
                  name:  'ユーザー',
                  email: 'sample@email.com'
                }
              }
          }.to change { User.find(user_staff.id).name }.from(user_staff.name).to('ユーザー')
        end

        it 'indexにリダイレクトされる' do
          expect(
            patch(user_path(user_staff),
              params: {
                user: {
                  name: 'ユーザー'
                }
              })
          ).to redirect_to users_path
        end

        describe '異常' do
          it '名前が空白でアップデートされない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  ' ',
                    email: 'sample@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).name }
          end

          it 'email更新時、認証なしではアップデートされない' do
            expect {
              patch user_path(user_staff),
                params: {
                  user: {
                    name:  'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { User.find(user_staff.id).email }
          end

          it '登録失敗するとエラーを出す' do
            expect(
              patch(user_path(user_staff),
                params: {
                  user: {
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
      describe 'システム管理者の場合' do
        before(:each) do
          current_system_admin(system_admin)
        end
  
        it 'ユーザーを削除する' do
          expect {
            delete user_path(user_staff), params: { id: user_staff.id }
          }.to change(User, :count).by(-1)
        end

        it 'indexにリダイレクトされる' do
          expect(
            delete(user_path(user_staff), params: { id: user_staff.id })
          ).to redirect_to users_path
        end
      end
    end

    describe '異常' do
      describe '自組織のオーナーの場合' do
        before(:each) do
          current_user(user_owner)
        end
  
        it '削除できない' do
          expect {
            delete user_path(user_staff), params: { id: user_staff.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user_staff), params: { id: user_staff.id })
          ).to redirect_to root_path
        end
      end
  
      describe '他組織のオーナーの場合' do
        before(:each) do
          current_user(another_user_owner)
        end
  
        it '削除できない' do
          expect {
            delete user_path(user_staff), params: { id: user_staff.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user_staff), params: { id: user_staff.id })
          ).to redirect_to root_path
        end
      end
  
      describe '本人の場合' do
        before(:each) do
          current_user(user_staff)
        end
  
        it '削除できない' do
          expect {
            delete user_path(user_staff), params: { id: user_staff.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user_staff), params: { id: user_staff.id })
          ).to redirect_to root_path
        end
      end
  
      describe '同組織の他スタッフの場合' do
        before(:each) do
          current_user(user_staff1)
        end
  
        it '削除できない' do
          expect {
            delete user_path(user_staff), params: { id: user_staff.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user_staff), params: { id: user_staff.id })
          ).to redirect_to root_path
        end
      end
  
      describe '他組織のスタッフの場合' do
        before(:each) do
          current_user(another_user_staff)
        end
  
        it '削除できない' do
          expect {
            delete user_path(user_staff), params: { id: user_staff.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user_staff), params: { id: user_staff.id })
          ).to redirect_to root_path
        end
      end
  
      describe 'ログインなしの場合' do
        it '削除できない' do
          expect {
            delete user_path(user_staff), params: { id: user_staff.id }
          }.not_to change(User, :count)
        end

        it 'rootにリダイレクトされる' do
          expect(
            delete(user_path(user_staff), params: { id: user_staff.id })
          ).to redirect_to root_path
        end
      end
    end
  end
end
