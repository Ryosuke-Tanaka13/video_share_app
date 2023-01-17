require 'rails_helper'

RSpec.xdescribe 'VideoStatusesSystem', type: :system, js: true do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }

  # orgにのみ属す
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  # orgとanother_orgの両方に属す
  let(:viewer1) { create(:viewer1, confirmed_at: Time.now) }

  let(:video_sample) { create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id) }

  # orgとviewerの紐付け
  let(:organization_viewer) { create(:organization_viewer) }
  # orgとviewer1の紐付け
  let(:organization_viewer2) { create(:organization_viewer2) }

  let(:video_sample_status) { create(:video_sample_status, video_id: video_sample.id, viewer_id: viewer.id) }
  let(:video_sample_status1) { create(:video_sample_status1, video_id: video_sample.id, viewer_id: viewer1.id) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
    viewer1
    video_sample
    organization_viewer
    organization_viewer2
    video_sample_status
    video_sample_status1
  end

  describe '正常' do
    describe '視聴状況一覧ページ' do
      before(:each) do
        sign_in system_admin
        visit video_statuses_path(video_sample)
      end

      it 'レイアウト' do
        expect(page).to have_text '●視聴が完了している視聴者の割合'
        expect(page).to have_text '→ 50 % (2人中1人が完了)'
        expect(page).to have_text '●視聴が完了している視聴者'
        expect(page).to have_text '名前'
        expect(page).to have_link viewer1.name, href: viewer_path(viewer1)
        expect(page).to have_text '視聴完了時刻'
        expect(page).to have_text '08/14 18:06'
        expect(page).to have_link '視聴状況の削除', href: video_status_hidden_path(video_sample_status1, video_id: video_sample.id)
        expect(page).to have_link '視聴状況の完全削除', href: video_status_path(video_sample_status1, video_id: video_sample.id)
        expect(page).to have_text '●視聴が完了していない視聴者'
        expect(page).to have_text '名前'
        expect(page).to have_text '視聴率'
        expect(page).to have_link viewer.name, href: viewer_path(viewer)
        expect(page).to have_text video_sample_status.watched_ratio
        expect(page).to have_link '視聴状況の削除', href: video_status_hidden_path(video_sample_status, video_id: video_sample.id)
        expect(page).to have_link '視聴状況の完全削除', href: video_status_path(video_sample_status, video_id: video_sample.id)
        find('#myChart')
      end

      it '視聴状況(100%)削除' do
        find(:xpath, '//*[@id="viewers-video_statuses-index"]/div[1]/div[1]/div[2]/div[1]/div/table/tbody/tr[2]/td[4]/a').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '視聴者1の視聴状況を削除します。本当によろしいですか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '削除しました。'
        }.to change(VideoStatus, :count).by(0)
      end

      it '視聴状況(100%)削除キャンセル' do
        find(:xpath, '//*[@id="viewers-video_statuses-index"]/div[1]/div[1]/div[2]/div[1]/div/table/tbody/tr[2]/td[4]/a').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '視聴者1の視聴状況を削除します。本当によろしいですか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(VideoStatus, :count)
      end

      it '視聴状況(100%未満)削除' do
        find(:xpath, '//*[@id="viewers-video_statuses-index"]/div[1]/div[1]/div[2]/div[2]/div/table/tbody/tr[2]/td[4]/a').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '視聴者の視聴状況を削除します。本当によろしいですか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '削除しました。'
        }.to change(VideoStatus, :count).by(0)
      end

      it '視聴状況(100%未満)削除キャンセル' do
        find(:xpath, '//*[@id="viewers-video_statuses-index"]/div[1]/div[1]/div[2]/div[2]/div/table/tbody/tr[2]/td[4]/a').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '視聴者の視聴状況を削除します。本当によろしいですか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(VideoStatus, :count)
      end
    end
  end

  describe '異常' do
    describe '視聴状況一覧ページ(オーナー)' do
      before(:each) do
        sign_in user_owner
        visit video_statuses_path(video_sample)
      end

      it 'レイアウトに物理削除のリンクなし' do
        expect(page).to have_text '●視聴が完了している視聴者の割合'
        expect(page).to have_text '→ 50 % (2人中1人が完了)'
        expect(page).to have_text '●視聴が完了している視聴者'
        expect(page).to have_text '名前'
        expect(page).to have_link viewer1.name, href: viewer_path(viewer1)
        expect(page).to have_text '視聴完了時刻'
        expect(page).to have_text '08/14 18:06'
        expect(page).to have_link '視聴状況の削除', href: video_status_hidden_path(video_sample_status1, video_id: video_sample.id)
        expect(page).to have_no_link '視聴状況の完全削除', href: video_status_path(video_sample_status1, video_id: video_sample.id)
        expect(page).to have_text '●視聴が完了していない視聴者'
        expect(page).to have_text '名前'
        expect(page).to have_text '視聴率'
        expect(page).to have_link viewer.name, href: viewer_path(viewer)
        expect(page).to have_text video_sample_status.watched_ratio
        expect(page).to have_link '視聴状況の削除', href: video_status_hidden_path(video_sample_status, video_id: video_sample.id)
        expect(page).to have_no_link '視聴状況の完全削除', href: video_status_path(video_sample_status, video_id: video_sample.id)
        find('#myChart')
      end
    end

    describe '視聴状況一覧ページ(スタッフ)' do
      before(:each) do
        sign_in user_staff
        visit video_statuses_path(video_sample)
      end

      it 'レイアウトに物理削除のリンクなし、論理削除のリンクなし、視聴者の名前はリンクではなくテキスト表示' do
        expect(page).to have_text '●視聴が完了している視聴者の割合'
        expect(page).to have_text '→ 50 % (2人中1人が完了)'
        expect(page).to have_text '●視聴が完了している視聴者'
        expect(page).to have_text '名前'
        expect(page).to have_no_link viewer1.name, href: viewer_path(viewer1)
        expect(page).to have_text viewer1.name
        expect(page).to have_text '視聴完了時刻'
        expect(page).to have_text '08/14 18:06'
        expect(page).to have_no_link '視聴状況の削除', href: video_status_hidden_path(video_sample_status1, video_id: video_sample.id)
        expect(page).to have_no_link '視聴状況の完全削除', href: video_status_path(video_sample_status1, video_id: video_sample.id)
        expect(page).to have_text '●視聴が完了していない視聴者'
        expect(page).to have_text '名前'
        expect(page).to have_text '視聴率'
        expect(page).to have_no_link viewer.name, href: viewer_path(viewer)
        expect(page).to have_text viewer.name
        expect(page).to have_text video_sample_status.watched_ratio
        expect(page).to have_no_link '視聴状況の削除', href: video_status_hidden_path(video_sample_status, video_id: video_sample.id)
        expect(page).to have_no_link '視聴状況の完全削除', href: video_status_path(video_sample_status, video_id: video_sample.id)
        find('#myChart')
      end
    end
  end
end
