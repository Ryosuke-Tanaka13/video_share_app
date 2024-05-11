require 'rails_helper'

RSpec.describe 'VideosPopups', type: :system, js: true do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }
  # orgにのみ属す
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }

  let(:video_sample) do
    create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id, folders: [folder_celeb, folder_tech])
  end
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb]) }
  let(:video_popup_before_test) do
    create(:video_popup_before_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb])
  end
  let(:video_popup_after_test) do
    create(:video_popup_after_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb])
  end
  let(:video_it) { create(:video_it, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  # orgとviewerの紐付け
  let(:organization_viewer) { create(:organization_viewer) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    video_sample
    video_test
    video_popup_before_test
    video_popup_after_test
    folder_celeb
    folder_tech
    organization_viewer
  end

  describe '正常' do
    describe 'ポップアップ表示なし' do
      before(:each) do
        sign_in user_owner || system_admin
        visit video_path(video_test)
      end

      it 'レイアウト' do
        expect(page).to have_text 'テストビデオ'
        expect(page).to have_link '設定'
        expect(page).to have_link '削除'
        expect(page).not_to have_link 'popb', visible: :hidden
        expect(page).not_to have_link 'popa', visible: :hidden
      end
    end

    describe '動画再生前ポップアップあり' do
      before(:each) do
        sign_in user_owner || system_admin
        visit video_path(video_popup_before_test)
      end

      it 'レイアウト' do
        expect(page).to have_link 'popb', visible: :hidden
        expect(page).not_to have_link 'popa', visible: :hidden
        expect(page).to have_text 'popup_before'
      end
    end

    describe '動画再生後ポップアップあり' do
      before(:each) do
        sign_in user_owner || system_admin
        visit video_path(video_popup_after_test)
      end

      it 'レイアウト' do
        expect(page).not_to have_link 'popb', visible: :hidden
        expect(page).to have_link 'popa', visible: :hidden
        expect(page).not_to have_text 'popup_before'
        # 非表示のリンクをクリックできないため、リンクの表示状態を変更
        page.execute_script("document.getElementById('hiddenPopupAfterLink').style.display = 'block';")
        page.execute_script("document.getElementById('hiddenPopupAfterLink').click();")
        expect(page).to have_text 'popup_after'
      end
    end
  end
end