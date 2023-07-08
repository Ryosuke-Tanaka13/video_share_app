require 'rails_helper'

RSpec.xdescribe 'Replies', type: :request do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:user_staff1) { create(:user_staff1, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:another_viewer) { create(:another_viewer) }
  let(:video_it) { create(:video_it, organization_id: organization.id, user_id: user.id) }
  let(:comment) { create(:comment, organization_id: organization.id, video_id: video_it.id, user_id: user.id) }
  let(:system_admin_reply) do
    create(:system_admin_reply, organization_id: user.organization_id, comment_id: comment.id, system_admin_id: system_admin.id)
  end
  let(:user_reply) { create(:user_reply, organization_id: user.organization_id, comment_id: comment.id, user_id: user.id) }
  let(:viewer_reply) { create(:viewer_reply, organization_id: user.organization_id, comment_id: comment.id, viewer_id: viewer.id) }

  before(:each) do
    organization
    system_admin
    user
    user_staff1
    viewer
    another_viewer
    video_it
    comment
    system_admin_reply
    user_reply
    viewer_reply
  end

  xdescribe 'Post #create' do
    xdescribe '正常' do
      xdescribe 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '返信が新規作成される' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: user_reply.comment_id),
              params: {
                reply: {
                  reply: 'システム管理者の返信'
                }, format: :js
              }
          }.to change(Reply, :count).by(1)
        end
      end

      xdescribe '動画投稿者' do
        before(:each) do
          current_user(user)
        end

        it '返信が新規作成される' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: user_reply.comment_id),
              params: {
                reply: {
                  reply: '動画投稿者の返信'
                }, format: :js
              }
          }.to change(Reply, :count).by(1)
        end
      end

      xdescribe '動画視聴者' do
        before(:each) do
          current_viewer(viewer)
        end

        it '返信が新規作成される' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: viewer_reply.comment_id),
              params: {
                reply: {
                  reply: '動画視聴者のコメント'
                }, format: :js
              }
          }.to change(Reply, :count).by(1)
        end
      end
    end

    xdescribe '異常' do
      xdescribe 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '返信が空白だと新規作成されない' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: viewer_reply.comment_id),
              params: {
                reply: {
                  reply: ''
                }, format: :js
              }
          }.not_to change(Reply, :count)
        end
      end

      xdescribe '動画投稿者' do
        before(:each) do
          current_user(user)
        end

        it '返信が空白だと新規作成されない' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: viewer_reply.comment_id),
              params: {
                reply: {
                  reply: ''
                }, format: :js
              }
          }.not_to change(Reply, :count)
        end
      end

      xdescribe '動画視聴者' do
        before(:each) do
          current_viewer(viewer)
        end

        it '返信が空白だと新規作成されない' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: viewer_reply.comment_id),
              params: {
                reply: {
                  reply: ''
                }, format: :js
              }
          }.not_to change(Reply, :count)
        end
      end
    end
  end

  xdescribe 'PATCH #update' do
    xdescribe 'システム管理者' do
      before(:each) do
        current_system_admin(system_admin)
      end

      xdescribe '正常' do
        it '返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者のアップデート返信'
                }, format: :js
              }
          }.to change { Reply.find(system_admin_reply.id).reply }.from(system_admin_reply.reply).to('システム管理者のアップデート返信')
        end

        it '動画投稿者の返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者からのアップデート返信'
                }, format: :js
              }
          }.to change { Reply.find(user_reply.id).reply }.from(user_reply.reply).to('システム管理者からのアップデート返信')
        end

        it '動画視聴者の返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者からのアップデート返信'
                }, format: :js
              }
          }.to change { Reply.find(viewer_reply.id).reply }.from(viewer_reply.reply).to('システム管理者からのアップデート返信')
        end
      end

      xdescribe '異常' do
        it '返信が空白ではアップデートされない' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: {
                reply: {
                  reply: ''
                }, format: :js
              }
          }.not_to change { Reply.find(system_admin_reply.id).reply }
        end
      end
    end

    xdescribe '動画投稿者' do
      before(:each) do
        current_user(user)
      end

      xdescribe '正常' do
        it '返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者のアップデート返信'
                }, format: :js
              }
          }.to change { Reply.find(user_reply.id).reply }.from(user_reply.reply).to('動画投稿者のアップデート返信')
        end
      end

      xdescribe '異常' do
        it '返信が空白ではアップデートされない' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: ''
                }, format: :js
              }
          }.not_to change { Reply.find(user_reply.id).reply }
        end

        xdescribe '別の動画投稿者' do
          before(:each) do
            current_user(user_staff1)
          end

          it '動画投稿者はシステム管理者の返信をアップデートできない' do
            expect {
              patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
                params: {
                  reply: {
                    reply: '別の動画投稿者の返信'
                  }, format: :js
                }
            }.not_to change { Reply.find(system_admin_reply.id).reply }
          end

          it '別の動画投稿者はアップデートできない' do
            expect {
              patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
                params: {
                  reply: {
                    reply: '別の動画投稿者の返信'
                  }, format: :js
                }
            }.not_to change { Reply.find(user_reply.id).reply }
          end

          it '動画投稿者は動画視聴者の返信をアップデートできない' do
            expect {
              patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
                params: {
                  reply: {
                    reply: '別の動画投稿者の返信'
                  }, format: :js
                }
            }.not_to change { Reply.find(viewer_reply.id).reply }
          end
        end
      end
    end

    xdescribe '動画視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      xdescribe '正常' do
        it '返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: '動画視聴者のアップデート返信'
                }, format: :js
              }
          }.to change { Reply.find(viewer_reply.id).reply }.from(viewer_reply.reply).to('動画視聴者のアップデート返信')
        end
      end

      xdescribe '異常' do
        it '返信が空白ではアップデートされない' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: ''
                }, format: :js
              }
          }.not_to change { Reply.find(viewer_reply.id).reply }
        end

        xdescribe '別の動画視聴者' do
          before(:each) do
            current_user(another_viewer)
          end

          it '別の動画視聴者はシステム管理者の返信をアップデートできない' do
            expect {
              patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
                params: {
                  reply: {
                    reply: '別の動画視聴者の返信'
                  }, format: :js
                }
            }.not_to change { Reply.find(system_admin_reply.id).reply }
          end

          it '別の動画視聴者は動画投稿者の返信をアップデートできない' do
            expect {
              patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
                params: {
                  reply: {
                    reply: '別の動画視聴者の返信'
                  }, format: :js
                }
            }.not_to change { Reply.find(user_reply.id).reply }
          end

          it '別の動画視聴者は動画視聴者の返信をアップデートできない' do
            expect {
              patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
                params: {
                  reply: {
                    reply: '別の動画視聴者の返信'
                  }, format: :js
                }
            }.not_to change { Reply.find(viewer_reply.id).reply }
          end
        end
      end
    end
  end

  xdescribe 'DELETE #destroy' do
    xdescribe 'システム管理者' do
      before(:each) do
        current_system_admin(system_admin)
      end

      xdescribe '正常' do
        it '返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: { id: system_admin.id, format: :js }
          }.to change(Reply, :count).by(-1)
        end

        it '動画投稿者の返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id, format: :js }
          }.to change(Reply, :count).by(-1)
        end

        it '動画視聴者の返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id, format: :js }
          }.to change(Reply, :count).by(-1)
        end
      end
    end

    xdescribe '動画投稿者' do
      before(:each) do
        current_user(user)
      end

      xdescribe '正常' do
        it '返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id, format: :js }
          }.to change(Reply, :count).by(-1)
        end
      end
    end

    xdescribe '動画視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      xdescribe '正常' do
        it '返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id, format: :js }
          }.to change(Reply, :count).by(-1)
        end
      end
    end

    xdescribe '返信作成者以外の別の動画投稿者が現在のログインユーザ' do
      before(:each) do
        current_user(user_staff1)
      end

      xdescribe '異常' do
        it '別の動画投稿者はシステム管理者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: { id: system_admin_reply.id, format: :js }
          }.not_to change(Reply, :count)
        end

        it '別の動画投稿者は動画投稿者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id, format: :js }
          }.not_to change(Reply, :count)
        end

        it '別の動画投稿者は動画視聴者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id, format: :js }
          }.not_to change(Reply, :count)
        end
      end
    end

    xdescribe '返信作成者以外の別の動画視聴者が現在のログインユーザ' do
      before(:each) do
        current_user(another_viewer)
      end

      xdescribe '異常' do
        it '別の動画視聴者はシステム管理者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: { id: system_admin_reply.id, format: :js }
          }.not_to change(Reply, :count)
        end

        it '別の動画視聴者は動画投稿者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id, format: :js }
          }.not_to change(Reply, :count)
        end

        it '別の動画視聴者は動画視聴者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id, format: :js }
          }.not_to change(Reply, :count)
        end
      end
    end
  end
end
