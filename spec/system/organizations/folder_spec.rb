# rubocop:disable RSpec/PendingWithoutReason
require 'rails_helper'

RSpec.xdescribe 'FolderSystem', :js, type: :system do
  # このテストは開発中でスキップされています。
  let(:organization) { create(:organization) }
  let(:another_organization) { create(:another_organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id) }
  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }
  let(:folder_other_owner) { create(:folder_other_owner, organization_id: another_user_owner.organization_id) }

  # フォルダ選択機能の実装の際にここから追記
  let(:video_sample) do
    create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id, folders: [folder_celeb, folder_tech])
  end
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb]) }

  before(:each) do
    organization
    another_organization
    system_admin
    user_owner
    another_user_owner
    user_staff
    folder_celeb
    folder_tech
    folder_other_owner
    video_sample
    video_test
  end

  describe '正常' do
    describe '動画フォルダ一覧ページ' do
      describe '組織管理者' do
        before(:each) do
          login(user_owner)
          current_user(user_owner)
          visit organization_folders_path(organization_id: organization.id)
        end

        it 'レイアウト' do
          expect(page).to have_text 'セレブエンジニア'
          expect(page).to have_text 'テックリーダーズ'
          expect(page).to have_link 'フォルダ新規作成'
          expect(page).to have_link '動画一覧'
          expect(page).to have_css('svg.fa-trash-alt')
        end

        it 'フォルダ削除' do
          find(:xpath, '//*[@id="organizations-folders-index"]/div[1]/div[1]/div[2]/div/table[2]/tbody/tr[2]/th/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'フォルダを削除しました'
          }.to change(Folder, :count).by(-1)
        end

        it 'フォルダ削除キャンセル' do
          find(:xpath, '//*[@id="organizations-folders-index"]/div[1]/div[1]/div[2]/div/table[2]/tbody/tr[2]/th/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(Folder, :count)
        end
      end

      describe 'システム管理者' do
        before(:each) do
          login_system_admin(system_admin)
          current_system_admin(system_admin)
          visit organization_folders_path(organization_id: organization.id)
        end

        it 'レイアウト' do
          expect(page).to have_text 'セレブエンジニア'
          expect(page).to have_text 'テックリーダーズ'
          expect(page).not_to have_link 'フォルダ新規作成'
          expect(page).to have_link '動画一覧'
          expect(page).to have_css('svg.fa-trash-alt')
        end
      end

      describe '動画投稿者' do
        before(:each) do
          login(user_staff)
          current_user(user_staff)
          visit organization_folders_path(organization_id: organization.id)
        end

        it 'レイアウト' do
          expect(page).to have_text 'セレブエンジニア'
          expect(page).to have_text 'テックリーダーズ'
          expect(page).to have_link 'フォルダ新規作成'
          expect(page).to have_link '動画一覧'
          expect(page).not_to have_css('svg.fa-trash-alt')
        end
      end
    end

    describe 'モーダル画面' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit organization_folders_path(organization_id: organization.id)
        click_link('フォルダ新規作成')
      end

      it 'モーダルが表示されていること' do
        expect(page).to have_selector('.modal')
      end

      it 'レイアウト' do
        expect(page).to have_link '新規作成'
        expect(page).to have_button '閉じる'
        expect(page).to have_field '名前'
      end

      it '新規作成でフォルダが作成される' do
        fill_in '名前', with: 'プログラミング'
        click_button '新規作成'
        expect(page).to have_text 'フォルダを作成しました！'
        expect(page).to have_text 'プログラミング'
      end
    end

    describe '名前更新' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit organization_folders_path(organization_id: organization.id)
      end

      it '名前を更新する' do
        find('th', text: 'セレブエンジニア').click
        find('input[type="text"]').set('プログラミング')
        find('h1', text: '動画フォルダ一覧').click
        expect(page).to have_text 'プログラミング'
        expect(page).not_to have_text 'セレブエンジニア'
      end
    end
  end

  # フォルダ選択機能の実装の際にここから追記
  describe '動画フォルダ詳細ページ' do
    describe 'システム管理者' do
      before(:each) do
        login_system_admin(system_admin)
        current_system_admin(system_admin)
        visit organization_folder_path(folder_celeb.organization_id, folder_celeb.id)
      end

      it 'レイアウト' do
        expect(page).to have_text 'サンプルビデオ'
        expect(page).to have_link 'フォルダ内から削除'
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_link 'フォルダ内から削除'
        expect(page).to have_no_text 'ITビデオ'
      end

      it 'フォルダ内から削除' do
        find(:xpath, '//*[@id="organizations-folders-show"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はフォルダ内からは削除されますが、動画自体は残ります'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '動画をフォルダ内から削除しました'
        }.to change(VideoFolder, :count).by(-1)
      end

      it 'フォルダ内から削除キャンセル' do
        find(:xpath, '//*[@id="organizations-folders-show"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はフォルダ内からは削除されますが、動画自体は残ります'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(VideoFolder, :count)
      end
    end

    describe '組織管理者' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit organization_folder_path(folder_celeb.organization_id, folder_celeb.id)
      end

      it 'レイアウト' do
        expect(page).to have_text 'サンプルビデオ'
        expect(page).to have_link 'フォルダ内から削除'
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_link 'フォルダ内から削除'
        expect(page).to have_no_text 'ITビデオ'
      end

      it 'フォルダ内から削除' do
        find(:xpath, '//*[@id="organizations-folders-show"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はフォルダ内からは削除されますが、動画自体は残ります'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '動画をフォルダ内から削除しました'
        }.to change(VideoFolder, :count).by(-1)
      end

      it 'フォルダ内から削除キャンセル' do
        find(:xpath, '//*[@id="organizations-folders-show"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はフォルダ内からは削除されますが、動画自体は残ります'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(VideoFolder, :count)
      end
    end

    describe '動画投稿者本人' do
      before(:each) do
        login(user_staff)
        current_user(user_staff)
        visit organization_folder_path(folder_celeb.organization_id, folder_celeb.id)
      end

      it 'レイアウト' do
        expect(page).to have_text 'サンプルビデオ'
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_link 'フォルダ内から削除'
        expect(page).to have_no_text 'ITビデオ'
      end

      it 'フォルダ内から削除' do
        find(:xpath, '//*[@id="organizations-folders-show"]/div[1]/div[1]/div[2]/div[2]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はフォルダ内からは削除されますが、動画自体は残ります'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '動画をフォルダ内から削除しました'
        }.to change(VideoFolder, :count).by(-1)
      end

      it 'フォルダ内から削除キャンセル' do
        find(:xpath, '//*[@id="organizations-folders-show"]/div[1]/div[1]/div[2]/div[2]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はフォルダ内からは削除されますが、動画自体は残ります'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(VideoFolder, :count)
      end
    end
  end
  # ここまで追記

  describe '異常' do
    describe 'モーダル画面' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit organization_folders_path(organization_id: organization.id)
        click_link('フォルダ新規作成')
      end

      it '名前重複' do
        fill_in '名前', with: 'セレブエンジニア'
        click_button '新規作成'
        expect(page).to have_text '名前はすでに存在します'
      end

      it '名前空白' do
        fill_in '名前', with: ''
        click_button '新規作成'
        expect(page).to have_text '名前を入力してください'
      end
    end

    describe 'フォルダ一覧画面' do
      before(:each) do
        login(user_owner)
        current_user(user_owner)
        visit organization_folders_path(organization_id: organization.id)
      end

      it '他の組織のフォルダは見れない' do
        expect(page).not_to have_text 'IT'
      end

      it '名前が空白で更新できない' do
        find('th', text: 'セレブエンジニア').click
        find('input[type="text"]').set(' ')
        find('h1', text: '動画フォルダ一覧').click
        expect(page).to have_text 'フォルダ名が空欄、もしくは同じフォルダ名があります'
      end

      it '名前が重複していて更新できない' do
        find('th', text: 'セレブエンジニア').click
        find('input[type="text"]').set('テックリーダーズ')
        find('h1', text: '動画フォルダ一覧').click
        expect(page).to have_text 'フォルダ名が空欄、もしくは同じフォルダ名があります'
      end
    end
  end
end
# rubocop:enable RSpec/PendingWithoutReason
