require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:video) { create(:video, organization_id: organization.id, user_id: user.id) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:another_viewer) { create(:another_viewer) }
  let(:user_comment) { create(:user_comment, organization_id: user.organization_id, video_id: video.id, user_id: user.id) }
  let(:viewer_comment) { create(:viewer_comment, organization_id: user.organization_id, video_id: video.id, viewer_id: viewer.id) }

  before(:each) do
    organization
    user
    video
    user_staff
    viewer
    another_viewer
    user_comment
    viewer_comment
  end

  describe 'Post #create' do
    describe '正常' do
      describe '動画投稿者' do
        before(:each) do
          current_user(user)
        end

        it 'コメントが新規作成される' do
          expect {
            post video_comments_path(video_id: user_comment.video_id),
            params: {
              comment: {
                comment: '動画投稿者のコメント'
              }
            }
          }.to change(Comment, :count).by(1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            post video_comments_path(video_id: user_comment.video_id),
            params: {
              comment: {
                comment: '動画投稿者のコメント'
              }
            }
          ).to redirect_to video_path(video)
        end
      end
    end

    describe '動画視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      it 'コメントが新規作成される' do
        expect {
          post video_comments_path(video_id: viewer_comment.video_id),
          params: {
            comment: {
              comment: '動画視聴者のコメント'
            }
          }
        }.to change(Comment, :count).by(1)
      end

      it 'videos#showにリダイレクトされる' do
        expect(
          post video_comments_path(video_id: viewer_comment.video_id),
          params: {
            comment: {
              comment: '動画視聴者のコメント'
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

        it 'コメントが空白だと新規作成されない' do
          expect {
            post video_comments_path(video_id: user_comment.video_id),
            params: {
              comment: {
                comment: ''
              }, format: :js
            }
          }.not_to change(Comment, :count)
        end
      end

      describe '動画視聴者' do
        before(:each) do
          current_viewer(viewer)
        end

        it 'コメントが空白だと新規作成されない' do
          expect {
            post video_comments_path(video_id: viewer_comment.video_id),
            params: {
              comment: {
                comment: ''
              }, format: :js
            }
          }.not_to change(Comment, :count)
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
        it 'コメントがアップデートされる' do
          expect {
            patch video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: '動画投稿者のアップデートコメント'
                }
              }
          }.to change { Comment.find(user_comment.id).comment }.from(user_comment.comment).to('動画投稿者のアップデートコメント')
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            patch(video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: '動画投稿者のアップデートコメント'
                }
              })
          ).to redirect_to video_path(video)
        end
      end

      describe '異常' do
        it 'コメントが空白ではアップデートされない' do
          expect {
            patch video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: ''
                }, format: :js
              }
          }.not_to change { Comment.find(user_comment.id).comment }
        end
      end
    end

    describe '動画視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      describe '正常' do
        it 'コメントがアップデートされる' do
          expect {
            patch video_comment_path(video_id: viewer_comment.video_id, id: viewer_comment.id),
              params: {
                comment: {
                  comment: '動画視聴者のアップデートコメント'
                }
              }
          }.to change { Comment.find(viewer_comment.id).comment }.from(viewer_comment.comment).to('動画視聴者のアップデートコメント')
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            patch(video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: '動画視聴者のアップデートコメント'
                }
              })
          ).to redirect_to video_path(video)
        end
      end

      describe '異常' do
        it 'コメントが空白ではアップデートされない' do
          expect {
            patch video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: ''
                }, format: :js
              }
          }.not_to change { Comment.find(user_comment.id).comment }
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
            patch video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: '別の動画投稿者のコメント'
                }, format: :js
              }
          }.not_to change { Comment.find(user_comment.id).comment }
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
            patch video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: '別の動画視聴者のコメント'
                }, format: :js
              }
          }.not_to change { Comment.find(user_comment.id).comment }
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    describe '動画投稿者' do
      before(:each) do
        current_user(user)
      end

      describe '正常' do
        it 'コメントを削除する' do
          expect {
            delete video_comment_path(video_id: user_comment.video_id, id: user_comment.id), params: { id: user_comment.id }
          }.to change(Comment, :count).by(-1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            delete(video_comment_path(video_id: user_comment.video_id, id: user_comment.id),
              params: {
                comment: {
                  comment: '動画投稿者のコメント'
                }
              })
          ).to redirect_to video_path(video)
        end
      end

      describe 'コメント作成者以外の別の動画投稿者が現在のログインユーザ' do
        before(:each) do
          current_user(user_staff)
        end

        describe '異常' do
          it '別の動画投稿者は削除できない' do
            expect {
              delete video_comment_path(video_id: user_comment.video_id, id: user_comment.id), params: { id: user_comment.id }
            }.not_to change(Comment, :count)
          end
        end
      end

      describe 'コメント作成者以外の別の動画視聴者が現在のログインユーザ' do
        before(:each) do
          current_user(another_viewer)
        end

        it '別の動画視聴者は削除できない' do
          expect {
            delete video_comment_path(video_id: user_comment.video_id, id: user_comment.id), params: { id: user_comment.id }
          }.not_to change(Comment, :count)
        end
      end
    end
  end
end
