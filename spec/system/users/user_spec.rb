require 'rails_helper'

RSpec.describe 'UserSystem', type: :system do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_staff1) { create(:user_staff1, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user_staff) { create(:another_user_staff, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_owner
    user_staff
    user_staff1
    another_organization
    another_user_owner
    another_user_staff
    system_admin
    viewer
  end

  context 'サイドバーの項目/遷移確認' do
    describe 'オーナ' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit users_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'レコブル'
        expect(page).to have_link user_owner.name
        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画投稿'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'

        visit viewers_path

        expect(page).to have_link 'レコブル'
        expect(page).to have_link user_owner.name
        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画投稿'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it 'レコブルへの遷移' do
        click_link 'レコブル'
        expect(page).to have_current_path organization_folders_path(organization), ignore_query: true
      end

      it '自身の名前への遷移' do
        click_link user_owner.name, match: :first
        expect(page).to have_current_path user_path(user_owner), ignore_query: true
      end

      it '動画フォルダ一覧への遷移' do
        click_link '動画フォルダ一覧'
        expect(page).to have_current_path organization_folders_path(organization), ignore_query: true
      end

      it '動画投稿への遷移' do
        click_link '動画投稿'
        expect(page).to have_current_path new_video_path, ignore_query: true
      end

      it '投稿者一覧への遷移' do
        click_link '投稿者一覧'
        expect(page).to have_current_path users_path, ignore_query: true
      end

      it '視聴者一覧への遷移' do
        click_link '視聴者一覧'
        expect(page).to have_current_path viewers_path, ignore_query: true
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_user_path(user_owner), ignore_query: true
      end
    end

    describe '動画投稿者' do
      before(:each) do
        login(user_staff)
        current_user(user_staff)
        visit users_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'レコブル'
        expect(page).to have_link user_staff.name
        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画投稿'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it 'レコブルへの遷移' do
        click_link 'レコブル'
        expect(page).to have_current_path organization_folders_path(organization), ignore_query: true
      end

      it '自身の名前への遷移' do
        click_link user_staff.name, match: :first
        expect(page).to have_current_path user_path(user_staff), ignore_query: true
      end

      it '動画フォルダ一覧への遷移' do
        click_link '動画フォルダ一覧'
        expect(page).to have_current_path organization_folders_path(organization), ignore_query: true
      end

      it '動画投稿への遷移' do
        click_link '動画投稿'
        expect(page).to have_current_path new_video_path, ignore_query: true
      end

      it '視聴者一覧への遷移' do
        click_link '視聴者一覧'
        expect(page).to have_current_path viewers_path, ignore_query: true
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_user_path(user_staff), ignore_query: true
      end
    end
  end

  context 'システム管理者操作' do
    before(:each) do
      login(system_admin)
      current_system_admin(system_admin)
    end

    describe '正常' do
      context '投稿者一覧ページ' do
        before(:each) do
          visit users_path(organization_id: user_owner.organization_id)
        end

        it 'レイアウト' do
          expect(page).to have_link user_owner.name, href: user_path(user_owner)
          expect(page).to have_link user_staff.name, href: user_path(user_staff)
          expect(page).to have_link '削除', href: user_path(user_owner)
          expect(page).to have_link '削除', href: user_path(user_staff)
        end

        it 'オーナー詳細への遷移' do
          click_link user_owner.name, match: :first
          expect(page).to have_current_path user_path(user_owner), ignore_query: true
        end

        it 'スタッフ詳細への遷移' do
          click_link user_staff.name
          expect(page).to have_current_path user_path(user_staff), ignore_query: true
        end

        it 'オーナー1削除' do
          find(:xpath, '//*[@id="users-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[2]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'オーナーのユーザー情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'オーナーのユーザー情報を削除しました'
          }.to change(User, :count).by(-1)
        end

        it 'オーナー削除キャンセル' do
          find(:xpath, '//*[@id="users-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[2]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'オーナーのユーザー情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(User, :count)
        end

        it 'スタッフ削除' do
          find(:xpath, '//*[@id="users-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[3]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'スタッフのユーザー情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'スタッフのユーザー情報を削除しました'
          }.to change(User, :count).by(-1)
        end

        it 'スタッフ削除キャンセル' do
          find(:xpath, '//*[@id="users-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[3]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'スタッフのユーザー情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(User, :count)
        end
      end

      context 'オーナー詳細' do
        before(:each) do
          visit user_path(user_owner)
        end

        it 'レイアウト' do
          expect(page).to have_text user_owner.email
          expect(page).to have_text user_owner.name
          expect(page).to have_text organization.name
          expect(page).to have_link '編集', href: edit_user_path(user_owner)
          expect(page).to have_link '戻る', href: users_path(organization_id: organization.id)
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_user_path(user_owner), ignore_query: true
        end

        it '戻るへの遷移' do
          click_link '戻る'
          expect(page).to have_current_path users_path, ignore_query: true
        end
      end
    end
  end

  context 'オーナー操作' do
    before(:each) do
      login(user_owner)
      current_user(user_owner)
    end

    describe '正常' do
      context '投稿者一覧ページ' do
        before(:each) do
          visit users_path(organization_id: user_owner.organization_id)
        end

        it 'レイアウト' do
          expect(page).to have_link '視聴者新規作成画面へ', href: new_user_path
          expect(page).to have_link user_owner.name, href: user_path(user_owner)
          expect(page).to have_link user_staff.name, href: user_path(user_staff)
          expect(page).to have_link '削除', href: users_unsubscribe_path(user_staff)
        end

        it '視聴者新規作成画面への遷移' do
          click_link '視聴者新規作成画面へ'
          expect(page).to have_current_path new_user_path, ignore_query: true
        end

        it 'オーナー詳細への遷移' do
          click_link user_owner.name, match: :first
          expect(page).to have_current_path user_path(user_owner), ignore_query: true
        end

        it 'スタッフ詳細への遷移' do
          click_link user_staff.name
          expect(page).to have_current_path user_path(user_staff), ignore_query: true
        end

        it 'スタッフ論理削除' do
          find(:xpath, '//*[@id="users-index"]/div[1]/div/div[2]/div/table/tbody/tr[3]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'スタッフのユーザー情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'スタッフのユーザー情報を削除しました'
          }.to change { User.find(user_staff.id).is_valid }.from(user_staff.is_valid).to(false)
        end

        it 'スタッフ論理削除キャンセル' do
          find(:xpath, '//*[@id="users-index"]/div[1]/div/div[2]/div/table/tbody/tr[3]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'スタッフのユーザー情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change { User.find(user_staff.id).is_valid }
        end
      end

      context 'オーナー詳細' do
        before(:each) do
          visit user_path(user_owner)
        end

        it 'レイアウト' do
          expect(page).to have_text user_owner.email
          expect(page).to have_text user_owner.name
          expect(page).to have_text organization.name
          expect(page).to have_link '編集', href: edit_user_path(user_owner)
          expect(page).to have_link '退会', href: users_unsubscribe_path(user_owner)
          expect(page).to have_link '戻る', href: users_path(organization_id: organization.id)
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_user_path(user_owner), ignore_query: true
        end

        it '退会への遷移' do
          click_link '退会'
          expect(page).to have_current_path users_unsubscribe_path(user_owner), ignore_query: true
        end

        it '戻るへの遷移' do
          click_link '戻る'
          expect(page).to have_current_path users_path, ignore_query: true
        end
      end

      context 'オーナー編集' do
        before(:each) do
          visit edit_user_path(user_owner)
        end

        it 'レイアウト' do
          expect(page).to have_field 'Name'
          expect(page).to have_field 'Eメール'
          expect(page).to have_button '更新'
          expect(page).to have_link '詳細画面へ'
          expect(page).to have_link '一覧画面へ'
        end

        it '更新で登録情報が更新される' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_current_path users_path, ignore_query: true
          expect(page).to have_text '更新しました'
        end
      end

      context 'スタッフ新規作成' do
        before(:each) do
          visit new_user_path(user_owner)
        end

        it 'レイアウト' do
          expect(page).to have_field 'Name'
          expect(page).to have_field 'Eメール'
          expect(page).to have_field 'パスワード'
          expect(page).to have_field 'パスワード（確認用）'
          expect(page).to have_button '登録'
          expect(page).to have_link '一覧画面へ'
        end

        it '登録でスタッフが新規作成される' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'sample@email.com'
          fill_in 'パスワード', with: 'password'
          fill_in 'パスワード（確認用）', with: 'password'
          click_button '登録'
          expect(page).to have_current_path users_path, ignore_query: true
          expect(page).to have_text 'testの作成に成功しました'
        end
      end
    end

    describe '異常' do
      context '投稿者一覧ページ' do
        before(:each) do
          visit users_path
        end

        it '別組織の投稿者は表示されない' do
          expect(page).not_to have_link another_user_owner.name, href: user_path(another_user_owner)
          expect(page).not_to have_link another_user_staff.name, href: user_path(another_user_staff)
        end
      end

      context 'オーナー編集' do
        before(:each) do
          visit edit_user_path(user_owner)
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

        it 'Eメール重複' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'owner_spec1@example.com'
          click_button '更新'
          expect(page).to have_text 'Eメールはすでに存在します'
        end
      end

      context 'スタッフ新規作成' do
        before(:each) do
          visit new_user_path(user_owner)
        end

        it 'Name空白' do
          fill_in 'Name', with: ''
          fill_in 'Eメール', with: 'sample@email.com'
          fill_in 'パスワード', with: 'password'
          fill_in 'パスワード（確認用）', with: 'password'
          click_button '登録'
          expect(page).to have_text 'Nameを入力してください'
        end

        it 'Name10文字以上' do
          fill_in 'Name', with: 'a' * 11
          fill_in 'Eメール', with: 'sample@email.com'
          fill_in 'パスワード', with: 'password'
          fill_in 'パスワード（確認用）', with: 'password'
          click_button '登録'
          expect(page).to have_text 'Nameは10文字以内で入力してください'
        end

        it 'Eメール空白' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: ''
          fill_in 'パスワード', with: 'password'
          fill_in 'パスワード（確認用）', with: 'password'
          click_button '登録'
          expect(page).to have_text 'Eメールを入力してください'
        end

        it 'Eメール存在' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'owner_spec1@example.com'
          fill_in 'パスワード', with: 'password'
          fill_in 'パスワード（確認用）', with: 'password'
          click_button '登録'
          expect(page).to have_text 'Eメールはすでに存在します'
        end

        it 'パスワード空白' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'test_spec2@example.com'
          fill_in 'パスワード', with: ''
          fill_in 'パスワード（確認用）', with: 'password'
          click_button '登録'
          expect(page).to have_text 'パスワードを入力してください'
        end

        it 'パスワード5文字' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'test_spec2@example.com'
          fill_in 'パスワード', with: 'a' * 5
          fill_in 'パスワード（確認用）', with: 'a' * 5
          click_button '登録'
          expect(page).to have_text 'パスワードは6文字以上で入力してください'
        end

        it 'パスワード（確認用）不一致' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'test_spec2@example.com'
          fill_in 'パスワード', with: 'a' * 5
          fill_in 'パスワード（確認用）', with: ''
          click_button '登録'
          expect(page).to have_text 'パスワード（確認用）とパスワードの入力が一致しません'
        end
      end
    end
  end

  context 'スタッフ操作' do
    before(:each) do
      login(user_staff)
      current_user(user_staff)
    end

    describe '正常' do
      context '投稿者一覧ページ' do
        before(:each) do
          visit users_path(organization_id: user_owner.organization_id)
        end

        it 'レイアウト' do
          expect(page).to have_text user_owner.name
          expect(page).to have_link user_staff.name, href: user_path(user_staff)
        end

        it 'スタッフ詳細への遷移' do
          click_link user_staff.name, match: :first
          expect(page).to have_current_path user_path(user_staff), ignore_query: true
        end
      end

      context 'スタッフ詳細' do
        before(:each) do
          visit user_path(user_staff)
        end

        it 'レイアウト' do
          expect(page).to have_text user_staff.email
          expect(page).to have_text user_staff.name
          expect(page).to have_text organization.name
          expect(page).to have_link '編集', href: edit_user_path(user_staff)
          expect(page).to have_link '退会', href: users_unsubscribe_path(user_staff)
          expect(page).to have_link '戻る', href: users_path(organization_id: organization.id)
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_user_path(user_staff), ignore_query: true
        end

        it '退会への遷移' do
          click_link '退会'
          expect(page).to have_current_path users_unsubscribe_path(user_staff), ignore_query: true
        end

        it '戻るへの遷移' do
          click_link '戻る'
          expect(page).to have_current_path users_path, ignore_query: true
        end
      end

      context 'スタッフ編集' do
        before(:each) do
          visit edit_user_path(user_staff)
        end

        it 'レイアウト' do
          expect(page).to have_field 'Name'
          expect(page).to have_field 'Eメール'
          expect(page).to have_button '更新'
          expect(page).to have_link '詳細画面へ'
          expect(page).to have_link '一覧画面へ'
        end

        it '更新で登録情報が更新される' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_current_path users_path, ignore_query: true
          expect(page).to have_text '更新しました'
        end
      end
    end

    describe '異常' do
      context '投稿者一覧ページ' do
        before(:each) do
          visit users_path
        end

        it '別組織の投稿者は表示されない' do
          expect(page).not_to have_link another_user_owner.name, href: user_path(another_user_owner)
          expect(page).not_to have_link another_user_staff.name, href: user_path(another_user_staff)
        end
      end

      context 'オーナー編集' do
        before(:each) do
          visit edit_user_path(user_staff)
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

        it 'Eメール重複' do
          fill_in 'Name', with: 'test'
          fill_in 'Eメール', with: 'owner_spec1@example.com'
          click_button '更新'
          expect(page).to have_text 'Eメールはすでに存在します'
        end
      end
    end
  end
end
