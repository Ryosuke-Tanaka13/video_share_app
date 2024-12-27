require 'rails_helper'

RSpec.xdescribe 'Comments', type: :system, js: true do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:video_it) { create(:video_it, organization_id: organization.id, user_id: user.id, login_set: false) }
  let(:user_staff1) { create(:user_staff1, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:organization_viewer) { create(:organization_viewer, organization_id: user.organization_id, viewer_id: viewer.id) }
  let(:another_viewer) { create(:another_viewer) }
  let(:system_admin_comment) do
    create(:system_admin_comment, organization_id: user.organization_id, video_id: video_it.id, user_id: user.id)
  end
  let(:user_comment) { create(:user_comment, organization_id: user.organization_id, video_id: video_it.id, user_id: user_staff1.id) }
  let(:viewer_comment) { create(:viewer_comment, organization_id: user.organization_id, video_id: video_it.id, viewer_id: viewer.id) }
  let(:system_admin_reply) do
    create(:system_admin_reply, system_admin_id: system_admin.id, organization_id: user.organization_id,
      comment_id: system_admin_comment.id)
  end

  before(:each) do
    organization
    system_admin
    user
    video_it
    user_staff1
    viewer
    organization_viewer
    another_viewer
    system_admin_comment
    user_comment
    viewer_comment
  end

  describe '正常' do
    describe 'システム管理者' do
      before(:each) do
        login_system_admin(system_admin)
        current_system_admin(system_admin)
        visit video_path(id: user_comment.video_id)
        click_button 'コメントを表示する'
      end

      it 'レイアウト' do
        expect(page).to have_field 'comment-text'
        expect(page).to have_css 'svg.fa-edit'
        expect(page).to have_css 'svg.fa-trash-alt'
      end

      it 'コメント投稿する' do
        fill_in 'comment[comment]', with: 'システム管理者のコメント'
        click_button '送信'
        expect(page).to have_text 'システム管理者のコメント'
        expect(page).to have_text 'コメント投稿に成功しました。'
      end

      it 'コメント編集' do
        all('div.js-edit-comment-button')[0].click
        comment_textarea = find('textarea.comment-post-error')
        comment_textarea.set('システム管理者のアップデートコメント')
        click_button '更新'
        expect(page).to have_content 'システム管理者のアップデートコメント'
      end

      it 'コメント編集キャンセル' do
        all('div.js-edit-comment-button')[0].click
        comment_textarea = find('textarea.comment-post-error')
        comment_textarea.set('システム管理者のアップデートコメント')
        click_button 'キャンセル'
        expect(page).not_to have_content 'システム管理者のアップデートコメント'
      end

      it 'コメント削除' do
        all('.fa-trash-alt')[0].click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'コメント削除に成功しました。'
        }.to change(Comment, :count).by(-1)
      end

      it 'コメント削除キャンセル' do
        all('.fa-trash-alt')[0].click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Comment, :count)
      end

      it 'コメント返信' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('システム管理者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        expect(page).to have_content 'システム管理者の返信'
      end

      it 'コメント返信編集' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('システム管理者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        find('div.js-edit-reply-button').click
        comment_textarea = find('textarea.reply-post-error')
        comment_textarea.set('システム管理者の返信アップデートコメント')
        click_button '更新'
        expect(page).to have_content('コメント返信の編集に成功しました。', wait: 10)
        click_button('1 件の返信')
        expect(page).to have_content 'システム管理者の返信アップデートコメント'
      end

      it 'コメント返信キャンセル' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('システム管理者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        all('div.js-edit-reply-button')[0].click
        comment_textarea = find('textarea.reply-post-error')
        comment_textarea.set('システム管理者の返信アップデートコメント')
        click_button 'キャンセル'
        expect(page).not_to have_content 'システム管理者の返信アップデートコメント'
      end

      it 'コメント返信削除' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('システム管理者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        reply = find('.content-show-comment-bottom-view-reply')
        reply.find('.fa-trash-alt').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'コメント返信の削除に成功しました。'
        }.to change(Reply, :count).by(-1)
        expect(page).not_to have_content '1 件の返信'
      end

      it 'コメント返信削除キャンセル' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('システム管理者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        reply = find('.content-show-comment-bottom-view-reply')
        reply.find('.fa-trash-alt').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Reply, :count)
        expect(page).to have_content 'システム管理者の返信'
      end
    end

    describe '動画投稿者' do
      before(:each) do
        login(user_staff1)
        current_user(user_staff1)
        visit video_path(id: user_comment.video_id)
        click_button 'コメントを表示する'
      end

      it 'レイアウト' do
        expect(page).to have_field 'comment-text'
        expect(page).to have_css('svg.fa-edit')
        expect(page).to have_css('svg.fa-trash-alt')
        all_comments = all('.content-show-comment-bottom-top')
        all_comments.each do |comment|
          commenter_name = comment.find('.content-show-comment-bottom-top-user-name').text
          if commenter_name != 'スタッフ1さん'
            expect(comment).not_to have_css('.js-edit-comment-button')
          end
        end
      end

      it 'コメント投稿する' do
        fill_in 'comment[comment]', with: '動画投稿者のコメント'
        click_button '送信'
        expect(page).to have_content '動画投稿者のコメント'
        expect(page).to have_content 'コメント投稿に成功しました。'
      end

      it 'コメント編集' do
        all('div.js-edit-comment-button')[0].click
        comment_textarea = find('textarea.comment-post-error')
        comment_textarea.set('動画投稿者のアップデートコメント')
        click_button '更新'
        expect(page).to have_content '動画投稿者のアップデートコメント'
      end

      it 'コメント編集キャンセル' do
        all('div.js-edit-comment-button')[0].click
        comment_textarea = find('textarea.comment-post-error')
        comment_textarea.set('動画投稿者のアップデートコメント')
        click_button 'キャンセル'
        expect(page).not_to have_content '動画投稿者のアップデートコメント'
      end

      it 'コメント削除' do
        all('.fa-trash-alt')[0].click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'コメント削除に成功しました。'
        }.to change(Comment, :count).by(-1)
      end

      it 'コメント削除キャンセル' do
        all('.fa-trash-alt')[0].click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Comment, :count)
      end

      it 'コメント返信' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画投稿者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        expect(page).to have_content '動画投稿者の返信'
      end

      it 'コメント返信編集' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画投稿者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        find('div.js-edit-reply-button').click
        comment_textarea = find('textarea.reply-post-error')
        comment_textarea.set('動画投稿者の返信アップデートコメント')
        click_button '更新'
        expect(page).to have_content('コメント返信の編集に成功しました。', wait: 10)
        click_button('1 件の返信')
        expect(page).to have_content '動画投稿者の返信アップデートコメント'
      end

      it 'コメント返信キャンセル' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画投稿者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        all('div.js-edit-reply-button')[0].click
        comment_textarea = find('textarea.reply-post-error')
        comment_textarea.set('動画投稿者の返信アップデートコメント')
        click_button 'キャンセル'
        expect(page).not_to have_content '動画投稿者の返信アップデートコメント'
      end

      it 'コメント返信削除' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画投稿者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        reply = find('.content-show-comment-bottom-view-reply')
        reply.find('.fa-trash-alt').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'コメント返信の削除に成功しました。'
        }.to change(Reply, :count).by(-1)
        expect(page).not_to have_content '1 件の返信'
      end

      it 'コメント返信削除キャンセル' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画投稿者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        reply = find('.content-show-comment-bottom-view-reply')
        reply.find('.fa-trash-alt').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Reply, :count)
        expect(page).to have_content '動画投稿者の返信'
      end

      it '他人の返信の編集、削除不可' do
        system_admin_reply
        visit video_path(id: user_comment.video_id)
        click_button 'コメントを表示する'
        click_button '1 件の返信'
        expect(page).to have_content 'system_adminの返信'
        expect(page).not_to have_css '.js-edit-reply-button'
        expect(page).not_to have_css '.content-show-comment-bottom-view-reply-top-icons-delete'
      end
    end

    describe '動画視聴者' do
      before(:each) do
        login(viewer)
        current_viewer(viewer)
        visit video_path(id: viewer_comment.video_id)
        click_button 'コメントを表示する'
      end

      it 'レイアウト' do
        expect(page).to have_field 'comment-text'
        expect(page).to have_css('svg.fa-edit')
        expect(page).to have_css('svg.fa-trash-alt')
        all_comments = all('.content-show-comment-bottom-top')
        all_comments.each do |comment|
          commenter_name = comment.find('.content-show-comment-bottom-top-user-name').text
          if commenter_name != '視聴者さん'
            expect(comment).not_to have_css('.js-edit-comment-button')
          end
        end
      end

      it 'コメント投稿する' do
        fill_in 'comment[comment]', with: 'test_comment'
        click_button '送信'
        expect(page).to have_content 'test_comment'
        expect(page).to have_content 'コメント投稿に成功しました。'
      end

      it 'コメント編集' do
        all('div.js-edit-comment-button')[0].click
        comment_textarea = find('textarea.comment-post-error')
        comment_textarea.set('動画視聴者のアップデートコメント')
        click_button '更新'
        expect(page).to have_content '動画視聴者のアップデートコメント'
      end

      it 'コメント編集キャンセル' do
        all('div.js-edit-comment-button')[0].click
        comment_textarea = find('textarea.comment-post-error')
        comment_textarea.set('動画視聴者のアップデートコメント')
        click_button 'キャンセル'
        expect(page).not_to have_content '動画視聴者のアップデートコメント'
      end

      it 'コメント削除' do
        all('.fa-trash-alt')[0].click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'コメント削除に成功しました。'
        }.to change(Comment, :count).by(-1)
      end

      it 'コメント削除キャンセル' do
        all('.fa-trash-alt')[0].click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Comment, :count)
      end

      it 'コメント返信' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画視聴者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        expect(page).to have_content '動画視聴者の返信'
      end

      it 'コメント返信編集' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画視聴者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        find('div.js-edit-reply-button').click
        comment_textarea = find('textarea.reply-post-error')
        comment_textarea.set('動画視聴者の返信アップデートコメント')
        click_button '更新'
        expect(page).to have_content('コメント返信の編集に成功しました。', wait: 10)
        click_button('1 件の返信')
        expect(page).to have_content '動画視聴者の返信アップデートコメント'
      end

      it 'コメント返信キャンセル' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('システム管理者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        all('div.js-edit-reply-button')[0].click
        comment_textarea = find('textarea.reply-post-error')
        comment_textarea.set('動画視聴者の返信アップデートコメント')
        click_button 'キャンセル'
        expect(page).not_to have_content '動画視聴者の返信アップデートコメント'
      end

      it 'コメント返信削除' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画視聴者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        reply = find('.content-show-comment-bottom-view-reply')
        reply.find('.fa-trash-alt').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'コメント返信の削除に成功しました。'
        }.to change(Reply, :count).by(-1)
        expect(page).not_to have_content '1 件の返信'
      end

      it 'コメント返信削除キャンセル' do
        all('.js-reply-form-button')[0].click
        comment_textarea = find('textarea#reply-text')
        comment_textarea.set('動画視聴者の返信')
        find('.content-show-comment-bottom-reply-btn').click
        click_button('1 件の返信')
        reply = find('.content-show-comment-bottom-view-reply')
        reply.find('.fa-trash-alt').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Reply, :count)
        expect(page).to have_content '動画視聴者の返信'
      end

      it '他人の返信の編集、削除不可' do
        system_admin_reply
        visit video_path(id: user_comment.video_id)
        click_button 'コメントを表示する'
        click_button '1 件の返信'
        expect(page).to have_content 'system_adminの返信'
        expect(page).not_to have_css '.js-edit-reply-button'
        expect(page).not_to have_css '.content-show-comment-bottom-view-reply-top-icons-delete'
      end
    end

    describe 'ログインなしユーザ' do
      before(:each) do
        system_admin_reply
        visit video_path(video_it.id)
        click_button 'コメントを表示する'
      end

      it 'レイアウト' do
        expect(page).not_to have_field 'comment-text'
        expect(page).not_to have_css 'svg.fa-edit'
        expect(page).not_to have_css 'svg.fa-trash-alt'
        click_button '1 件の返信'
        expect(page).to have_content 'system_adminの返信'
        expect(page).not_to have_css '.js-edit-reply-button'
        expect(page).not_to have_css '.content-show-comment-bottom-view-reply-top-icons-delete'
      end
    end
  end
end
