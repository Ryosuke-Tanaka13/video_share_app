# require 'rails_helper'

# RSpec.describe 'Commnets', type: :system, js: true do
#   let(:organization) { create(:organization) }
#   let(:system_admin) { create(:system_admin) }
#   let(:user) { create(:user, organization_id: organization.id) }
#   let(:video_it) { create(:video_it, organization_id: organization.id, user_id: user.id) }
#   let(:user_staff1) { create(:user_staff1, organization_id: organization.id) }
#   let(:viewer) { create(:viewer) }
#   let(:organization_viewer) { create(:organization_viewer, organization_id: user.organization_id, viewer_id: viewer.id) }
#   let(:another_viewer) { create(:another_viewer) }
#   let(:system_admin_comment) { create(:system_admin_comment, organization_id: user.organization_id, video_id: video_it.id, user_id: user.id) }
#   let(:user_comment) { create(:user_comment, organization_id: user.organization_id, video_id: video_it.id, user_id: user_staff1.id) }
#   let(:viewer_comment) { create(:viewer_comment, organization_id: user.organization_id, video_id: video_it.id, viewer_id: viewer.id) }

#   before(:each) do
#     organization
#     system_admin
#     user
#     video_it
#     user_staff1
#     viewer
#     organization_viewer
#     another_viewer
#     system_admin_comment
#     user_comment
#     viewer_comment
#   end

#   describe '正常' do
#     describe 'システム管理者' do
#       before(:each) do
#         login_system_admin(system_admin)
#         current_system_admin(system_admin)
#         visit video_path(id: user_comment.video_id)
#       end

#       it 'レイアウト' do
#         expect(page).to have_field 'comment-text'
#         expect(page).to have_css('svg.fa-pen-to-square')
#         expect(page).to have_css('svg.fa-trash-can')
#       end

#       it 'コメント投稿する' do
#         fill_in 'comment[comment]', with: 'システム管理者のコメント'
#         click_button '送信'
#         expect(page).to have_text 'システム管理者のコメント'
#         expect(page).to have_text 'コメント投稿に成功しました。'
#       end

#       it 'コメント編集' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[1]/svg/path').click
#         fill_in 'comment', with: 'システム管理者のアップデートコメント'
#         click_button '更新'
#         expect(page).to have_content 'システム管理者のアップデートコメント'
#       end

#       it 'コメント編集キャンセル' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[1]/svg').click
#         fill_in 'comment-text', with: 'システム管理者のアップデートコメント'
#         click_button '更新'
#         expect(page).to have_content 'システム管理者のアップデートコメント'
#         expect {
#           page.driver.browser.switch_to.alert.dismiss
#         }.not_to change(Comment, :count)
#       end

#       it 'コメント削除' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[3]/a/svg/path').click
#         expect {
#           expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
#           page.driver.browser.switch_to.alert.accept
#           expect(page).to have_content 'コメント削除に成功しました。'
#         }.to change(Comment, :count).by(-1)
#       end

#       it 'コメント削除キャンセル' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[3]/a').click
#         expect {
#           expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
#           page.driver.browser.switch_to.alert.dismiss
#         }.not_to change(Comment, :count)
#       end
#     end

#     describe '動画投稿者' do
#       before(:each) do
#         login(user_staff1)
#         current_user(user_staff1)
#         visit video_path(id: user_comment.video_id)
#       end

#       it 'レイアウト' do
#         expect(page).to have_field 'comment-text'
#         expect(page).to have_css('svg.fa-pen-to-square')
#         expect(page).to have_css('svg.fa-trash-can')
#       end

#       it 'コメント投稿する' do
#         fill_in 'comment[comment]', with: '動画投稿者のコメント'
#         click_button '送信'
#         expect(page).to have_content '動画投稿者のコメント'
#         expect(page).to have_content 'コメント投稿に成功しました。'
#       end

#       it 'コメント編集' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[1]/svg').click
#         fill_in 'comment', with: '動画投稿者のアップデートコメント'
#         click_button '更新'
#         expect(page).to have_content '動画投稿者のアップデートコメント'
#       end

#       it 'コメント編集キャンセル' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[1]/svg').click
#         expect {
#           page.driver.browser.switch_to.alert.dismiss
#         }.not_to change(Comment, :count)
#       end

#       it 'コメント削除' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[3]/a/svg/path').click
#         expect {
#           expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
#           page.driver.browser.switch_to.alert.accept
#           expect(page).to have_content 'コメント削除に成功しました。'
#         }.to change(Comment, :count).by(-1)
#       end

#       it 'コメント削除キャンセル' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[3]/a').click
#         expect {
#           expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
#           page.driver.browser.switch_to.alert.dismiss
#         }.not_to change(Comment, :count)
#       end
#     end

#     describe '動画視聴者' do
#       before(:each) do
#         login(viewer)
#         current_viewer(organization_viewer)
#         visit video_path(id: viewer_comment.video_id)
#       end

#       it 'レイアウト' do
#         expect(page).to have_field 'comment-text'
#         expect(page).to have_css('svg.fa-pen-to-square')
#         expect(page).to have_css('svg.fa-trash-can')
#       end

#       it 'コメント投稿する' do
#         fill_in 'comment[comment]', with: 'test_comment'
#         click_button '送信'
#         expect(page).to have_content 'test_comment'
#         expect(page).to have_content 'コメント投稿に成功しました。'
#       end

#       it 'コメント編集' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[1]/svg').click
#         fill_in 'comment', with: '動画視聴者のアップデートコメント'
#         click_button '更新'
#         expect(page).to have_content '動画視聴者のアップデートコメント'
#       end

#       it 'コメント編集キャンセル' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[1]/svg').click
#         expect {
#           page.driver.browser.switch_to.alert.dismiss
#         }.not_to change(Comment, :count)
#       end

#       it 'コメント削除' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[3]/a/svg/path').click
#         expect {
#           expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
#           page.driver.browser.switch_to.alert.accept
#           expect(page).to have_content 'コメント削除に成功しました。'
#         }.to change(Comment, :count).by(-1)
#       end

#       it 'コメント削除キャンセル' do
#         find(:xpath, '//*[@id="comments_area"]/div/div[1]/div[2]/div[2]/div[3]/a').click
#         expect {
#           expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
#           page.driver.browser.switch_to.alert.dismiss
#         }.not_to change(Comment, :count)
#       end
#     end

#     describe 'ログインなしユーザ' do
#       before(:each) do
#         visit video_path(id: user_comment.video_id)
#       end

#       it 'レイアウト' do
#         expect(page).not_to have_css('comment-text')
#         expect(page).not_to have_css('svg.fa-pen-to-square')
#         expect(page).not_to have_css('svg.fa-trash-can')
#       end
#     end

#     describe 'フォーム画面' do
#       before(:each) do
#         login(system_admin)
#         current_user(system_admin)
#         visit video_path(id: user_comment.video_id)
#         click_link('送信')
#       end
#     end
#   end
# end
