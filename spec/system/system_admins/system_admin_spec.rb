require 'rails_helper'

RSpec.describe 'SystemAdmin', type: :system do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_owner
    user_staff
    system_admin
    viewer
  end

  context 'サイドバーの項目/遷移確認' do
    before(:each) do
      system_admin
    end

    context 'システム管理者' do
      before(:each) do
        login(system_admin)
        current_system_admin(system_admin)
        visit system_admin_path(system_admin)
      end

      it 'レイアウト' do
        expect(page).to have_link 'レコブル'
        expect(page).to have_link system_admin.name
        expect(page).to have_link '組織一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'

        visit users_path(organization_id: organization.id)

        expect(page).to have_link 'レコブル'
        expect(page).to have_link system_admin.name
        expect(page).to have_link '組織一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'

        viewers_path(organization_id: organization.id)

        expect(page).to have_link 'レコブル'
        expect(page).to have_link system_admin.name
        expect(page).to have_link '組織一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it 'レコブルへの遷移' do
        click_link 'レコブル'
        expect(page).to have_current_path organizations_path, ignore_query: true
      end

      it '自身の名前への遷移' do
        click_link system_admin.name, match: :first
        expect(page).to have_current_path system_admin_path(system_admin), ignore_query: true
      end

      it '組織一覧への遷移' do
        click_link '組織一覧'
        expect(page).to have_current_path organizations_path, ignore_query: true
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_system_admin_path(system_admin), ignore_query: true
      end
    end
  end

  context 'SystemAdmin操作' do
    describe '正常' do
      context 'システム管理者詳細' do
        before(:each) do
          login(system_admin)
          current_system_admin(system_admin)
          visit system_admin_path(system_admin)
        end

        it 'レイアウト' do
          expect(page).to have_text system_admin.email
          expect(page).to have_text system_admin.name
          expect(page).to have_link '編集', href: edit_system_admin_path(system_admin)
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_system_admin_path(system_admin), ignore_query: true
        end
      end

      context 'システム管理者編集' do
        before(:each) do
          login(system_admin)
          current_system_admin(system_admin)
          visit edit_system_admin_path(system_admin)
        end

        it 'レイアウト' do
          expect(page).to have_field 'Name'
          expect(page).to have_field 'Eメール'
          expect(page).to have_button '更新'
          expect(page).to have_link '詳細画面へ'
        end

        it '更新で登録情報が更新される' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_current_path system_admin_path(system_admin), ignore_query: true
          expect(page).to have_text '更新しました'
        end
      end
    end

    describe '異常' do
      context 'システム管理者編集' do
        before(:each) do
          login(system_admin)
          current_system_admin(system_admin)
          visit edit_system_admin_path(system_admin)
        end

        it 'Name空白' do
          fill_in 'Name', with: ''
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_text 'Nameを入力してください'
        end

        it 'Name10文字以上' do
          fill_in 'Name', with: 'a' * 11
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_text 'Nameは10文字以内で入力してください'
        end

        it 'Eメール空白' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: ''
          click_button '更新'
          expect(page).to have_text 'Eメールを入力してください'
        end
      end
    end
  end
end
