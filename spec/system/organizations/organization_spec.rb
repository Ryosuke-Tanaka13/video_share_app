# rubocop:disable RSpec/PendingWithoutReason
require 'rails_helper'

RSpec.xdescribe 'OrganizationSystem', :js, type: :system do
  # このテストは開発中であり、現在の実装に影響を与える可能性があるためスキップされています。
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  let(:user_staff1) { create(:user_staff1, confirmed_at: Time.now) }
  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }

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
    video_sample
    another_organization
    another_user_owner
    another_user_staff
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
        expect(page).to have_link 'レコブル'
        expect(page).to have_link system_admin.name
        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'

        visit users_path(organization_id: organization.id)

        expect(page).to have_link 'レコブル'
        expect(page).to have_link system_admin.name
        expect(page).to have_link '組織一覧'
        expect(page).to have_link 'アカウント編集'

        viewers_path(organization_id: organization.id)

        expect(page).to have_link 'レコブル'
        expect(page).to have_link system_admin.name
        expect(page).to have_link '組織一覧'
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
      context '組織一覧ページ' do
        before(:each) do
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
          }.to change(Organization, :count).by(-1) && change(Video, :count).by(-1)
        end

        it 'another_organization削除キャンセル' do
          find(:xpath, '//*[@id="organizations-index"]/div[1]/div[1]/div[2]/div/table/tbody/tr[3]/td[4]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'テックリーダーズの組織情報を削除します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(Organization, :count)
        end
      end

      context '組織詳細' do
        before(:each) do
          visit organization_path(organization)
        end

        it 'レイアウト' do
          expect(page).to have_text organization.name
          expect(page).to have_text organization.email
          expect(page).to have_link '編集', href: edit_organization_path(organization)
          expect(page).to have_link '退会', href: organizations_unsubscribe_path(organization)
          expect(page).to have_link '投稿者一覧', href: users_path(organization_id: organization.id)
          expect(page).to have_link '視聴者一覧', href: viewers_path(organization_id: organization.id)
          expect(page).to have_link '動画フォルダ一覧', href: organization_folders_path(organization)
          expect(page).to have_link '戻る', href: organizations_path
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_organization_path(organization), ignore_query: true
        end

        it '退会への遷移' do
          click_link '退会'
          expect(page).to have_current_path organizations_unsubscribe_path(organization), ignore_query: true
        end

        it '投稿者一覧への遷移' do
          click_link '投稿者一覧', match: :first
          expect(page).to have_current_path users_path, ignore_query: true
        end

        it '視聴者一覧への遷移' do
          click_link '視聴者一覧', match: :first
          expect(page).to have_current_path viewers_path, ignore_query: true
        end

        it '動画フォルダ一覧への遷移' do
          click_link '動画フォルダ一覧'
          expect(page).to have_current_path organization_folders_path(organization), ignore_query: true
        end

        it '戻るの遷移' do
          click_link '戻る', match: :first
          expect(page).to have_current_path organizations_path, ignore_query: true
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
      context '組織詳細' do
        before(:each) do
          visit organization_path(organization)
        end

        it 'レイアウト' do
          expect(page).to have_text organization.name
          expect(page).to have_text organization.email
          expect(page).to have_link '編集', href: edit_organization_path(organization)
          expect(page).to have_link '退会', href: organizations_unsubscribe_path(organization)
          expect(page).to have_link '投稿者一覧', href: users_path(organization_id: organization.id)
          expect(page).to have_link '視聴者一覧', href: viewers_path(organization_id: organization.id)
          expect(page).to have_link '動画フォルダ一覧'
        end

        it '編集への遷移' do
          click_link '編集'
          expect(page).to have_current_path edit_organization_path(organization), ignore_query: true
        end

        it '退会への遷移' do
          click_link '退会'
          expect(page).to have_current_path organizations_unsubscribe_path(organization), ignore_query: true
        end

        it '投稿者一覧への遷移' do
          click_link '投稿者一覧', match: :first
          expect(page).to have_current_path users_path, ignore_query: true
        end

        it '視聴者一覧への遷移' do
          click_link '視聴者一覧', match: :first
          expect(page).to have_current_path viewers_path, ignore_query: true
        end

        it '動画フォルダ一覧への遷移' do
          click_link '動画フォルダ一覧', match: :first
          expect(page).to have_current_path organization_folders_path(organization), ignore_query: true
        end
      end

      context '組織編集' do
        before(:each) do
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
      context '組織編集' do
        before(:each) do
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
          fill_in '組織のEメール', with: 'org_spec1@example.com'
          click_button '更新'
          expect(page).to have_text '組織のEメールはすでに存在します'
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
      context '組織詳細' do
        before(:each) do
          visit organization_path(organization)
        end

        it 'レイアウト' do
          expect(page).to have_text organization.name
          expect(page).to have_text organization.email
          expect(page).to have_link '投稿者一覧', href: users_path(organization_id: organization.id)
          expect(page).to have_link '視聴者一覧', href: viewers_path(organization_id: organization.id)
          expect(page).to have_link '動画フォルダ一覧', href: organization_folders_path(organization)
        end

        it '投稿者一覧への遷移' do
          click_link '投稿者一覧', match: :first
          expect(page).to have_current_path users_path, ignore_query: true
        end

        it '視聴者一覧への遷移' do
          click_link '視聴者一覧', match: :first
          expect(page).to have_current_path viewers_path, ignore_query: true
        end

        it '動画フォルダ一覧への遷移' do
          click_link '動画フォルダ一覧', match: :first
          expect(page).to have_current_path organization_folders_path(organization), ignore_query: true
        end
      end
    end
  end
end
# rubocop:enable RSpec/PendingWithoutReason
