require 'rails_helper'

RSpec.describe 'OrganizationSystem', type: :system do
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

  context 'サイドバーの項目/遷移確認' do
    describe 'システム管理者' do
      before(:each) do
        login(system_admin)
        current_system_admin(system_admin)
        visit system_admin_path(system_admin)
      end

      it 'レイアウト' do
        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'

        visit users_path

        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'

        viewers_path

        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_system_admin_path(system_admin), ignore_query: true
      end
    end

    describe 'オーナ' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit users_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画投稿'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'

        visit viewers_path

        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画投稿'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'
      end

      # it '動画一覧への遷移' do
      # click_link '動画フォルダ一覧'
      # expect(page).to have_current_path folders_path, ignore_query: true
      # end

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
        login(user)
        current_user(user)
        visit users_path
      end

      it 'レイアウト' do
        expect(page).to have_link 'アンケート作成'
        expect(page).to have_link '対象Grの設定'
        expect(page).to have_link '動画録画'
        expect(page).to have_link '動画投稿'
        expect(page).to have_link '動画フォルダ一覧'
        expect(page).not_to have_link '投稿者一覧'
        expect(page).to have_link '視聴者一覧'
        expect(page).to have_link 'アカウント編集'
      end

      it '視聴者一覧への遷移' do
        click_link '視聴者一覧'
        expect(page).to have_current_path viewers_path, ignore_query: true
      end

      it 'アカウント編集への遷移' do
        click_link 'アカウント編集'
        expect(page).to have_current_path edit_user_path(user), ignore_query: true
      end
    end
  end

  context 'Organization操作' do
    describe '正常' do
      describe '組織一覧ページ' do
        before(:each) do
          login(system_admin)
          current_system_admin(system_admin)
          visit organizations_path
        end

        it 'レイアウト' do
          expect(page).to have_link organization.name, href: organization_path(organization)
          expect(page).to have_link another_organization.name, href: organization_path(another_organization)
        end

        it 'organization詳細への遷移' do
          click_link organization.name, match: :first
          expect(page).to have_current_path organization_path(organization), ignore_query: true
        end

        it 'another_organization詳細への遷移' do
          click_link another_organization.name
          expect(page).to have_current_path organization_path(another_organization), ignore_query: true
        end

        it 'organization削除' do
          find(:xpath, '//*[@id="organizations-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[2]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'セレブエンジニアの組織情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'セレブエンジニアを削除しました'
          }.to change(Organization, :count).by(-1)
        end

        it 'another_organization削除キャンセル' do
          find(:xpath, '//*[@id="organizations-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[3]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'テックリーダーズの組織情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(Organization, :count)
        end
      end

      describe '組織詳細' do
        before(:each) do
          login(user_owner)
          current_user(user_owner)
          visit organization_path(organization)
        end

        it 'レイアウト' do
          expect(page).to have_text organization.name
          expect(page).to have_text organization.email
          expect(page).to have_link '編集', href: edit_organization_path(organization)
          expect(page).to have_link '投稿者一覧'
          expect(page).to have_link '動画フォルダ一覧'
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_organization_path(organization), ignore_query: true
        end

        it '投稿者一覧への遷移' do
          click_link '投稿者一覧', match: :first
          expect(page).to have_current_path users_path, ignore_query: true
        end

        # it '動画フォルダ一覧への遷移' do
        #   click_link '動画フォルダ一覧'
        #   expect(page).to have_current_path folders_path, ignore_query: true
        # end
      end

      describe '組織編集' do
        before(:each) do
          login(user_owner)
          current_user(user_owner)
          visit edit_organization_path(organization)
        end

        it 'レイアウト' do
          expect(page).to have_field '組織名'
          expect(page).to have_field '組織のEメール'
          expect(page).to have_button '更新'
          expect(page).to have_link '詳細画面へ'
        end

        it '更新で登録情報が更新される' do
          fill_in '組織名', with: 'test'
          fill_in '組織のEメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_current_path organization_path(organization), ignore_query: true
          expect(page).to have_text '更新しました'
        end
      end
    end

    describe '異常' do
      describe '組織編集' do
        before(:each) do
          login(user_owner)
          current_user(user_owner)
          visit edit_organization_path(organization)
        end

        it '組織名空白' do
          fill_in '組織名', with: ''
          fill_in '組織のEメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_text '組織名を入力してください'
        end

        it '組織名10文字以上' do
          fill_in '組織名', with: 'a' * 11
          fill_in '組織のEメール', with: 'sample@email.com'
          click_button '更新'
          expect(page).to have_text '組織名は10文字以内で入力してください'
        end

        it '組織のEメール空白' do
          fill_in '組織名', with: 'test'
          fill_in '組織のEメール', with: ''
          click_button '更新'
          expect(page).to have_text '組織のEメールを入力してください'
        end

        it '組織のEメール重複' do
          fill_in '組織名', with: 'test'
          fill_in '組織のEメール', with: 'org2@example.com'
          click_button '更新'
          expect(page).to have_text '組織のEメールはすでに存在します'
        end
      end
    end
  end
end
