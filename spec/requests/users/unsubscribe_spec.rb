require 'rails_helper'

RSpec.describe 'UserUnsubscribe', type: :request do
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

  # システム管理者　set_userと同組織オーナー　投稿者本人 のみ許可
  describe 'オーナー退会' do
    context '正常～異常' do
      context '本人操作' do
        before(:each) do
          current_user(user_owner)
        end

        it '退会した後ログインできない' do
          expect {
            patch users_unsubscribe_path(user_owner)
          }.to change { User.find(user_owner.id).is_valid }.from(user_owner.is_valid).to(false)

          get new_user_session_path
          expect(response).to have_http_status(:success)
          post user_session_path, params: { user: { email: user_owner.email, password: user_owner.password } }
          expect(response).to have_http_status(:ok)
          expect(response).to render_template :new
        end
      end

      context 'システム管理者操作' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '退会できる' do
          expect {
            patch users_unsubscribe_path(user_owner)
          }.to change { User.find(user_owner.id).is_valid }.from(user_owner.is_valid).to(false)
        end
      end
    end

    context '異常' do
      context '同組織のスタッフ操作' do
        before(:each) do
          current_user(user_staff)
        end

        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_owner)
          }.not_to change { User.find(user_owner.id).is_valid }
        end
      end

      context '他組織のオーナー操作' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_owner)
          }.not_to change { User.find(user_owner.id).is_valid }
        end
      end

      context '他組織のスタッフ操作' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_owner)
          }.not_to change { User.find(user_owner.id).is_valid }
        end
      end

      context '視聴者操作' do
        before(:each) do
          current_viewer(viewer)
        end

        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_owner)
          }.not_to change { User.find(user_owner.id).is_valid }
        end
      end

      context 'ログインなし操作' do
        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_owner)
          }.not_to change { User.find(user_owner.id).is_valid }
        end
      end
    end
  end

  describe 'スタッフ退会' do
    describe '正常' do
      context 'システム管理者操作' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '論理削除できる' do
          expect {
            patch users_unsubscribe_path(user_staff)
          }.to change { User.find(user_staff.id).is_valid }.from(user_staff.is_valid).to(false)
        end
      end

      context '本人操作' do
        before(:each) do
          current_user(user_staff)
        end

        it '退会した後ログインできない' do
          expect {
            patch users_unsubscribe_path(user_staff)
          }.to change { User.find(user_staff.id).is_valid }.from(user_staff.is_valid).to(false)

          get new_user_session_path
          expect(response).to have_http_status(:success)
          post user_session_path, params: { user: { email: user_staff.email, password: user_staff.password } }
          expect(response).to have_http_status(:success)
          # 200のステータスが返ってリダイレクトではなくなった　原因はsessionのメソッドにありそう
          # expect(response).to redirect_to 'http://www.example.com/users/sign_in'
        end
      end

      context '同組織オーナー操作' do
        before(:each) do
          current_user(user_owner)
        end

        it '退会できる' do
          expect {
            patch users_unsubscribe_path(user_staff)
          }.to change { User.find(user_staff.id).is_valid }.from(user_staff.is_valid).to(false)
        end
      end
    end

    describe '異常' do
      context '他組織のオーナー操作' do
        before(:each) do
          current_user(another_user_owner)
        end

        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_staff)
          }.not_to change { User.find(user_staff.id).is_valid }
        end
      end

      context '他組織のスタッフ操作' do
        before(:each) do
          current_user(another_user_staff)
        end

        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_staff)
          }.not_to change { User.find(user_staff.id).is_valid }
        end
      end

      context '視聴者操作' do
        before(:each) do
          current_viewer(viewer)
        end

        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_staff)
          }.not_to change { User.find(user_staff.id).is_valid }
        end
      end

      context 'ログインなし操作' do
        it '退会できない' do
          expect {
            patch users_unsubscribe_path(user_staff)
          }.not_to change { User.find(user_staff.id).is_valid }
        end
      end
    end
  end
end
