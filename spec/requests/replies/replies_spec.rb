require 'rails_helper'

RSpec.describe 'Replies', type: :request do
  let(:organization) { create(:organization) }
  let(:system_admin) { create(:system_admin) }
  let(:user) { create(:user, organization_id: organization.id) }
  let(:user_staff1) { create(:user_staff1, organization_id: organization.id) }
  let(:viewer) { create(:viewer) }
  let(:another_viewer) { create(:another_viewer) }
  let(:video_it) { create(:video_it, organization_id: organization.id, user_id: user.id) }
  let(:comment) { create(:comment, organization_id: organization.id, video_id: video_it.id) }
  let(:system_admin_reply) { create(:system_admin_reply, organization_id: user.organization_id, comment_id: comment.id) }
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

  describe 'Post #create' do
    describe '正常' do
      describe 'システム管理者' do
        before(:each) do
          current_system_admin(system_admin)
        end

        it '返信が新規作成される' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: user_reply.comment_id),
              params: {
                reply: {
                  reply: 'システム管理者の返信'
                }
              }
          }.to change(Reply, :count).by(1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            post(video_comment_replies_path(video_id: video_it.id, comment_id: user_reply.comment_id),
              params: {
                reply: {
                  reply: 'システム管理者の返信'
                }
              })
          ).to redirect_to video_path(video_it.id)
        end
      end
    end

    describe '正常' do
      describe '動画投稿者' do
        before(:each) do
          current_user(user)
        end

        it '返信が新規作成される' do
          expect {
            post video_comment_replies_path(video_id: video_it.id, comment_id: user_reply.comment_id),
              params: {
                reply: {
                  reply: '動画投稿者の返信'
                }
              }
          }.to change(Reply, :count).by(1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            post(video_comment_replies_path(video_id: video_it.id, comment_id: user_reply.comment_id),
              params: {
                reply: {
                  reply: '動画投稿者の返信'
                }
              })
          ).to redirect_to video_path(video_it.id)
        end
      end
    end

    describe '動画視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      it '返信が新規作成される' do
        expect {
          post video_comment_replies_path(video_id: video_it.id, comment_id: viewer_reply.comment_id),
            params: {
              reply: {
                reply: '動画視聴者のコメント'
              }
            }
        }.to change(Reply, :count).by(1)
      end

      it 'videos#showにリダイレクトされる' do
        expect(
          post(video_comment_replies_path(video_id: video_it.id, comment_id: viewer_reply.comment_id),
            params: {
              reply: {
                reply: '動画視聴者の返信'
              }
            })
        ).to redirect_to video_path(video_it)
      end
    end

    describe '異常' do
      describe 'システム管理者' do
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

      describe '動画投稿者' do
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

      describe '動画視聴者' do
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

  describe 'PATCH #update' do
    describe 'システム管理者' do
      before(:each) do
        current_system_admin(system_admin)
      end

      describe '正常' do
        it '返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者のアップデート返信'
                }
              }
          }.to change { Reply.find(system_admin_reply.id).reply }.from(system_admin_reply.reply).to('システム管理者のアップデート返信')
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            patch(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者のアップデート返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end

        it '動画投稿者の返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者からのアップデート返信'
                }
              }
          }.to change { Reply.find(user_reply.id).reply }.from(user_reply.reply).to('システム管理者からのアップデート返信')
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            patch(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者からのアップデート返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end

        it '動画視聴者の返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者からのアップデート返信'
                }
              }
          }.to change { Reply.find(viewer_reply.id).reply }.from(viewer_reply.reply).to('システム管理者からのアップデート返信')
        end
  
        it 'videos#showにリダイレクトされる' do
          expect(
            patch(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者からのアップデート返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end
      end

      describe '異常' do
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

    describe '動画投稿者' do
      before(:each) do
        current_user(user)
      end

      describe '正常' do
        it '返信がアップデートされる' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者のアップデート返信'
                }
              }
          }.to change { Reply.find(user_reply.id).reply }.from(user_reply.reply).to('動画投稿者のアップデート返信')
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            patch(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者のアップデート返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end
      end

      describe '異常' do
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
      end
    end
  end

  describe '別の動画投稿者' do
    before(:each) do
      current_user(user_staff1)
    end

    describe '異常' do
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

  describe '動画視聴者' do
    before(:each) do
      current_viewer(viewer)
    end

    describe '正常' do
      it '返信がアップデートされる' do
        expect {
          patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
            params: {
              reply: {
                reply: '動画視聴者のアップデート返信'
              }
            }
        }.to change { Reply.find(viewer_reply.id).reply }.from(viewer_reply.reply).to('動画視聴者のアップデート返信')
      end

      it 'videos#showにリダイレクトされる' do
        expect(
          patch(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
            params: {
              reply: {
                reply: '動画視聴者のアップデート返信'
              }
            })
        ).to redirect_to video_path(video_it)
      end
    end

    describe '異常' do
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
    end

    describe '別の動画視聴者' do
      before(:each) do
        current_user(another_viewer)
      end

      describe '異常' do
        it '動画視聴者はシステム管理者の返信をアップデートできない' do
          expect {
            patch video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: '別の動画視聴者の返信'
                }, format: :js
              }
          }.not_to change { Reply.find(viewer_reply.id).reply }
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

        it '別の動画視聴者はアップデートできない' do
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

  describe 'DELETE #destroy' do
    describe 'システム管理者' do
      before(:each) do
        current_system_admin(system_admin)
      end

      describe '正常' do
        it '返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id }
          }.to change(Reply, :count).by(-1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            delete(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: 'システム管理者の返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end

        it '動画投稿者の返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id }
          }.to change(Reply, :count).by(-1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            delete(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者の返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end

        it '動画視聴者の返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id }
          }.to change(Reply, :count).by(-1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            delete(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: '動画視聴者の返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end
      end
    end

    describe '動画投稿者' do
      before(:each) do
        current_user(user)
      end

      describe '正常' do
        it '返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id }
          }.to change(Reply, :count).by(-1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            delete(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: {
                reply: {
                  reply: '動画投稿者の返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end
      end
    end

    describe '動画視聴者' do
      before(:each) do
        current_viewer(viewer)
      end

      describe '正常' do
        it '返信を削除する' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id }
          }.to change(Reply, :count).by(-1)
        end

        it 'videos#showにリダイレクトされる' do
          expect(
            delete(video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: {
                reply: {
                  reply: '動画視聴者の返信'
                }
              })
          ).to redirect_to video_path(video_it)
        end
      end
    end

    describe '返信作成者以外の別の動画投稿者が現在のログインユーザ' do
      before(:each) do
        current_user(user_staff1)
      end

      describe '異常' do
        it '別の動画投稿者はシステム管理者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: { id: system_admin_reply.id }
          }.not_to change(Reply, :count)
        end

        it '別の動画投稿者は動画投稿者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id }
          }.not_to change(Reply, :count)
        end

        it '別の動画投稿者は動画視聴者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id }
          }.not_to change(Reply, :count)
        end
      end
    end

    describe '返信作成者以外の別の動画視聴者が現在のログインユーザ' do
      before(:each) do
        current_user(another_viewer)
      end

      describe '異常' do
        it '別の動画視聴者はシステム管理者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: system_admin_reply.id),
              params: { id: system_admin_reply.id }
          }.not_to change(Comment, :count)
        end

        it '別の動画視聴者は動画投稿者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: user_reply.id),
              params: { id: user_reply.id }
          }.not_to change(Comment, :count)
        end

        it '別の動画視聴者は動画視聴者の返信を削除できない' do
          expect {
            delete video_comment_reply_path(video_id: video_it.id, comment_id: user_reply.comment_id, id: viewer_reply.id),
              params: { id: viewer_reply.id }
          }.not_to change(Comment, :count)
        end
      end
    end
  end
end
