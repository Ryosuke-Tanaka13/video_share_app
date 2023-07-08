require 'rails_helper'

RSpec.xdescribe 'OrganizationAdmissionSystem', type: :system do
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

  xdescribe '組織加入' do
    xdescribe '正常' do
      context '視聴者本人' do
        before(:each) do
          login(another_viewer)
          current_viewer(another_viewer)
          visit organizations_admission_path(organization)
        end

        it '加入しないへの遷移' do
          click_link '加入しない'
          expect(page).to have_current_path viewer_path(another_viewer), ignore_query: true
        end

        it '視聴者の加入' do
          expect {
            click_link '加入する'
            expect(page).to have_content 'セレブエンジニアへ加入しました。'
          }.to change(OrganizationViewer, :count).by(1)
        end
      end
    end
  end

  xdescribe '組織脱退' do
    xdescribe '正常' do
      context '視聴者本人' do
        before(:each) do
          login(viewer)
          current_viewer(viewer)
          visit viewer_path(viewer)
        end

        it '脱退する' do
          find(:xpath, '//*[@id="viewers-show"]/div[1]/div/div[2]/div[1]/table/tbody/tr[3]/td[2]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'セレブエンジニアを脱退します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content 'セレブエンジニアを脱退しました。'
          }.to change(OrganizationViewer, :count).by(-1)
        end

        it '脱退キャンセル' do
          find(:xpath, '//*[@id="viewers-show"]/div[1]/div/div[2]/div[1]/table/tbody/tr[3]/td[2]/a').click
          expect {
            expect(page.driver.browser.switch_to.alert.text).to eq 'セレブエンジニアを脱退します。本当によろしいですか？'
            page.driver.browser.switch_to.alert.dismiss
          }.not_to change(OrganizationViewer, :count)
        end
      end
    end
  end
end
