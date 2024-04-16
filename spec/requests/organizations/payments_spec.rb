require 'rails_helper'

RSpec.describe 'Organizations::Payments', type: :request do
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

  describe 'GET #new' do
    describe '正常' do
      context '正規オーナー' do
        before(:each) do
          login_session(user_owner)
          current_user(user_owner)
          get new_organizations_payment_path(organization)
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
      context 'システム管理者' do
        before(:each) do
          login_session(system_admin)
          current_system_admin(system_admin)
          get new_organizations_payment_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '別組織のオーナー' do
        before(:each) do
          login_session(another_user_owner)
          current_user(another_user_owner)
          get new_organizations_payment_path(organization)
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
          get new_organizations_payment_path(organization)
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
          get new_organizations_payment_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end
    end
  end
end
