require 'rails_helper'

RSpec.describe 'Organizations::Admission', type: :request do
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
  let(:admin_viewer) { create(:admin_viewer) }
  let(:member_viewer) { create(:member_viewer) }
  let(:guest_viewer) { create(:guest_viewer) }

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
    admin_viewer
    member_viewer
    guest_viewer
  end

  # 組織へ未加入の視聴者　のみ許可
  describe 'GET #edit 組織加入ページの権限' do
    describe '正常' do
      context '未所属の視聴者' do
        before(:each) do
          current_viewer(another_viewer)
          get organizations_admission_path(organization)
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
          current_system_admin(system_admin)
          get organizations_admission_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '所属オーナー' do
        before(:each) do
          current_user(user_owner)
          get organizations_admission_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '所属スタッフ' do
        before(:each) do
          current_user(user_staff)
          get organizations_admission_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '他組織オーナー' do
        before(:each) do
          current_user(another_user_owner)
          get organizations_admission_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '他組織スタッフ' do
        before(:each) do
          current_user(another_user_staff)
          get organizations_admission_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context '所属済視聴者' do
        before(:each) do
          current_viewer(viewer)
          get organizations_admission_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end

      context 'ログインなし' do
        before(:each) do
          get organizations_admission_path(organization)
        end

        it 'アクセス権限なしのためリダイレクト' do
          expect(response).to have_http_status :found
          expect(response).to redirect_to root_url
        end
      end
    end
  end

  # 組織へ未加入の視聴者　のみ許可
  describe 'PATCH #update 組織加入の権限' do
    describe '正常' do
      context '未所属の視聴者' do
        before(:each) do
          current_viewer(another_viewer)
        end

        it '組織へ加入する' do
          expect {
            patch organizations_admission_path(organization)
          }.to change(OrganizationViewer, :count).by(1)
        end
      end
    end

    describe '異常' do
      context 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '組織へ加入出来ない' do
          expect {
            patch organizations_admission_path(organization)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '所属オーナー' do
        before(:each) do
          current_user(user_owner)
        end

        it '組織へ加入出来ない' do
          expect {
            patch organizations_admission_path(organization)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '所属スタッフ' do
        before(:each) do
          current_user(user_staff)
        end

        it '組織へ加入出来ない' do
          expect {
            patch organizations_admission_path(organization)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '他組織オーナー' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '組織へ加入出来ない' do
          expect {
            patch organizations_admission_path(organization)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '他組織スタッフ' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '組織へ加入出来ない' do
          expect {
            patch organizations_admission_path(organization)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '所属済視聴者' do
        before(:each) do
          current_viewer(viewer)
        end

        it '組織へ加入出来ない' do
          expect {
            patch organizations_admission_path(organization)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context 'ログインなし' do
        it '組織へ加入出来ない' do
          expect {
            patch organizations_admission_path(organization)
          }.not_to change(OrganizationViewer, :count)
        end
      end
    end
  end

  # set_organizationへ所属済の視聴者　システム管理者　set_organizationのオーナー　視聴者本人　のみ許可
  describe 'DELETE #destroy 組織脱退の権限' do
    describe '正常' do
      context 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '組織から脱退できる' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.to change(OrganizationViewer, :count).by(-1)
        end
      end

      context '所属オーナー' do
        before(:each) do
          current_user(user_owner)
        end

        it '組織から脱退できる' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.to change(OrganizationViewer, :count).by(-1)
        end
      end

      context '所属済視聴者' do
        before(:each) do
          current_viewer(viewer)
        end

        it '組織から脱退できる' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.to change(OrganizationViewer, :count).by(-1)
        end
      end
    end

    describe '異常' do
      context '所属スタッフ' do
        before(:each) do
          current_user(user_staff)
        end

        it '組織から脱退できない' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '他組織オーナー' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '組織から脱退できない' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '他組織スタッフ' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '組織から脱退できない' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context '未所属視聴者' do
        before(:each) do
          current_viewer(another_viewer)
        end

        it '組織から脱退できない' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.not_to change(OrganizationViewer, :count)
        end
      end

      context 'ログインなし' do
        it '組織から脱退できない' do
          expect {
            delete organizations_admission_path(organization, viewer_id: viewer.id)
          }.not_to change(OrganizationViewer, :count)
        end
      end
    end
  end
end
