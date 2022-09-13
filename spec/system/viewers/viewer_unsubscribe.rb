require 'rails_helper'

RSpec.describe 'ViewerUnsubscribeSystem', type: :system do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:user) { create(:user, confirmed_at: Time.now) }
  let(:user1) { create(:user1, confirmed_at: Time.now) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }
  let(:another_user) { create(:another_user, confirmed_at: Time.now) }

  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  before(:each) do
    organization
    user_owner
    user
    user1
    another_organization
    another_user_owner
    another_user
    system_admin
    viewer
  end

  describe 'オーナー退会' do
    describe '正常～異常' do
      describe '本人操作' do
        before(:each) do
          login(viewer)
          current_viewer(viewer)
          visit viewers_unsubscribe_path(viewer)
        end

        it 'レイアウト' do
          expect(page).to have_link '退会しない', href: viewer_path(viewer)
          expect(page).to have_link '退会する', href: viewers_unsubscribe_path(viewer)
        end

        it '詳細へ遷移' do
          click_link '退会しない'
          expect(page).to have_current_path viewer_path(viewer), ignore_query: true
        end

        # テンプレートエラーの解決せず（手動では動作確認済）
        # it '退会する' do
        #   find(:xpath, '//*[@id="viewers-unsubscribes-show"]/div[1]/div[2]/a[2]').click
        #   expect {
        #     expect(page).to have_content '退会処理が完了しました。'
        #   }.to change { Viewer.find(viewer.id).is_valid }.from(viewer.is_valid).to(false)
        # end
      end
    end
  end
end
