class RepliesController < ApplicationController
  include CommentReply
  before_action :set_comment_id
  before_action :ensure_system_admin_or_user_or_viewer
  before_action :system_admin_or_correct_user_viewer_reply, only: %i[update destroy]
  before_action :account_logged_in?
  helper_method :account_logged_in?
  protect_from_forgery { :except => [:destroy] }

  def create
    # videoのidを取得
    set_video_id
    # videoに紐づいたコメントを取得
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
    @reply = @comment.replies.build(reply_params)
    @replies = @comment.replies.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
    # コメント返信したアカウントをセット
    set_replyer_id
    if @reply.save
      flash.now[:success] = 'コメント返信に成功しました。'
    else
      flash.now[:danger] = 'コメント返信に失敗しました。'
    end
    render template: 'comments/index'
  end

  def update
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
    if @reply.update(reply_params)
      flash.now[:success] = 'コメント返信の編集に成功しました。'
    else
      flash.now[:danger] = 'コメント返信の編集に失敗しました。'
    end
    render template: 'comments/index'
  end

  def destroy
    if @reply.destroy
      flash[:success] = 'コメント返信の削除に成功しました。'
      redirect_to video_url(@comment.video_id)
    else
      flash.now[:danger] = 'コメント返の削除に失敗しました。'
      render template: 'comments/index'
    end
  end

  private

  def reply_params
    params.require(:reply).permit(:reply, :comment_id, :organization_id).merge(
      comment_id: @comment.id, organization_id: @video.organization_id
    )
  end

  def set_comment_id
    @comment = Comment.find(params[:comment_id])
  end

  # コメント返信したアカウントのidをセット
  def set_replyer_id
    if current_system_admin
      @reply.system_admin_id = current_system_admin.id
    elsif current_user
      @reply.user_id = current_user.id
    elsif current_viewer
      @reply.viewer_id = current_viewer.id
    end
  end

  # システム管理者またはコメント返信した動画投稿者、動画視聴者本人のみ許可
  def system_admin_or_correct_user_viewer_reply
    @reply = Reply.find(params[:id])
    set_video_id
    if !current_system_admin && (@reply.user_id != current_user&.id || @reply.viewer_id != current_viewer&.id)
      redirect_to video_url(@video.id), flash: { danger: '権限がありません' }
    end
  end
end
