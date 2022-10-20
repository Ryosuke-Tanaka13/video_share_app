require 'rails_helper'

RSpec.describe "Replies", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:another_viewer) { create(:another_viewer) }
  let(:video) { create(:video, organization_id: organization.id, user_id: user.id) }
  let(:comment) { create(:comment, organization_id: organization.id, video_id: video.id) }
  let(:user_reply) { create(:user_reply, organization_id: user.organization_id, comment_id: comment.id, user_id: user.id) }
  let(:viewer_reply) { create(:viewer_reply, organization_id: user.organization_id, comment_id: comment.id) }

  before(:each) do
    organization
    user
    user_staff
    viewer
    another_viewer
    video
    comment
    user_reply
    viewer_reply
  end
  
  describe 'Post #create' do
    describe '正常' do
      describe '動画投稿者' do
        before(:each) do
          current_user(user)
        end

        it '返信が新規作成される' do
          expect{
            post video_comment_replies_path(video_id: video.id, comment_id: user_reply.comment_id),
            params: {
              reply: {
                reply: '動画投稿者の返信'
              }
            }
          }.to change(Reply, :count).by(1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            post video_comment_replies_path(video_id: video.id, comment_id: user_reply.comment_id),
            params: {
              reply:{
                reply:'動画投稿者の返信'
              }
            }
          ).to redirect_to video_path(video.id)
        end
      end
    end

    describe '動画視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      it '返信が新規作成される' do
        expect{
          post video_comment_replies_path(video_id: video.id, comment_id: viewer_reply.comment_id),
          params: {
            reply: {
              reply: '動画視聴者のコメント'
            }
          }
        }.to change(Reply, :count).by(1)
      end

      it 'videos#showにリダイレクトされる' do
        expect(
          post video_comment_replies_path(video_id: video.id, comment_id: viewer_reply.comment_id),
          params: {
            reply:{
              reply:'動画視聴者の返信'
            }
          }
        ).to redirect_to video_path(video)
      end
    end

    describe '異常' do
      describe '動画投稿者' do
        before(:each) do
          current_user(user)
        end

        it '返信が空白だと新規作成されない' do
          expect{
            post video_comment_replies_path(video_id: video.id, comment_id: viewer_reply.comment_id),
            params: {
              reply:{
                reply:''
              }, format: :js
            }
          }.not_to change(Reply, :count)
        end
      end

      describe '動画視聴者' do
        before(:each) do
          current_viewer(viewer)
        end

        it '返信が空白だと新規作成されない' do
          expect{
            post video_comment_replies_path(video_id: video.id, comment_id: viewer_reply.comment_id),
            params: {
              reply:{
                reply:''
              }, format: :js
            }
          }.not_to change(Reply, :count)
        end
      end
    end
  end

  describe 'PATCH #update' do
    describe '動画投稿者' do
      before(:each) do
        current_user(user)
      end

      describe '正常' do
        it '返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者のアップデート返信'
                }
              }
          }.to change { Reply.find(user_reply.id).reply }.from(user_reply.reply).to('動画投稿者のアップデート返信')
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            patch(video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者のアップデート返信'
                }
              })
          ).to redirect_to video_path(video)
        end
      end

      describe '異常' do
        it '返信が空白ではアップデートされない' do
          expect {
            patch video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: ''
                }, format: :js
              }
          }.not_to change { Reply.find(user_reply.id).reply }
        end
      end
    end
  end

  describe '別の動画投稿者' do
    before(:each) do
      current_user(user_staff)
    end

    describe '異常' do
      it '別の動画投稿者はアップデートできない' do
        expect {
          patch video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id),
            params: {
              reply: {
                reply: '別の動画投稿者の返信'
              }, format: :js
            }
        }.not_to change { Reply.find(user_reply.id).reply }
      end
    end
  end

  describe '別の動画視聴者' do
    before(:each) do
      current_user(another_viewer)
    end

    describe '異常' do
      it '別の動画視聴者はアップデートできない' do
        expect {
          patch video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id),
            params: {
              reply: {
                reply: '別の動画視聴者の返信'
              }, format: :js
            }
        }.not_to change { Reply.find(user_reply.id).reply }
      end
    end
  end


  describe 'DELETE #destroy' do
    describe '動画投稿者' do
      before(:each) do
        current_user(user)
      end

      describe '正常' do
        it '返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id), params: { id: user_reply.id }
          }.to change(Reply, :count).by(-1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            delete(video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者の返信'
                }
              })
          ).to redirect_to video_path(video)
        end
      end
    end

    describe '返信作成者以外の別の動画投稿者が現在のログインユーザ' do
      before(:each) do
        current_user(user_staff)
      end

      describe '異常' do
        it '別の動画投稿者は削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id), params: { id: user_reply.id }
          }.not_to change(Reply, :count)
        end
      end
    end

    describe '返信作成者以外の別の動画視聴者が現在のログインユーザ' do
      before(:each) do
        current_user(another_viewer)
      end

      describe '異常' do
        it '別の動画視聴者は削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video.id, comment_id: user_reply.comment_id, id: user_reply.id), params: { id: user_reply.id }
          }.not_to change(Comment, :count)
        end
      end
    end
  end
end
