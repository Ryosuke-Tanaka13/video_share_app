require 'rails_helper'

RSpec.describe 'SystemAdmin', type: :request do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  

  before(:each) do
    organization
    user_owner
    user
    system_admin
    viewer
  end

  describe 'PATCH #update' do
    describe 'オーナー情報の編集' do
      describe '本人の場合' do
        before(:each) do
          current_system_admin(system_admin)
        end
  
        describe '正常' do
          it '同組織のオーナはアップデートできる' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name: 'ユーザー',
                    email: 'test_spec@example.com'
                  }
                }
            }.to change { SystemAdmin.find(system_admin.id).name }.from(system_admin.name).to('ユーザー')
          end
        end
      end
    
      describe 'オーナーの場合' do
        before(:each) do
          current_user(user_owner)
        end
  
        describe '異常' do
          it '別組織のオーナはアップデートできない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end
        end
      end

      describe 'スタッフの場合' do
        before(:each) do
          current_user(user)
        end
  
        describe '異常' do
          it '別組織のオーナはアップデートできない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
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
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end
        end
      end

      describe 'ログインなしの場合' do
        describe '異常' do
          it 'ログインなしはアップデートできない' do
            expect {
              patch system_admin_path(system_admin),
                params: {
                  system_admin: {
                    name: 'user',
                    email: 'sample_u@email.com'
                  }
                }
            }.not_to change { SystemAdmin.find(system_admin.id).name }
          end
        end
      end
    end
  end

  describe 'GET #show' do
    describe 'システム管理者詳細' do
      describe '本人の場合' do
        describe '正常' do
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

      describe 'オーナーの場合' do
        describe '異常' do
          before(:each) do
            current_user(user_owner)
            get system_admin_path(system_admin)
          end
    
          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end
      
      describe 'スタッフの場合' do
        describe '異常' do
          before(:each) do
            current_user(user)
            get system_admin_path(system_admin)
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
            get system_admin_path(system_admin)
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
            get system_admin_path(system_admin)
          end

          it 'アクセス権限なしのためリダイレクト' do
            expect(response).to have_http_status ' 302'
            expect(response).to redirect_to root_path
          end
        end
      end
    end
  end
end
