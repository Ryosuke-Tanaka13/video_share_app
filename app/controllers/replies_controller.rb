class RepliesController < ApplicationController
  include CommentReply
  before_action :set_account
  before_action :set_reply, only: %i[update destroy]
  before_action :set_video_id, only: %i[create update]
  before_action :set_comment_id
  before_action :ensure_user_or_viewer
  before_action :correct_user_reply_or_correct_viewer_reply, only: %i[update destroy]
  helper_method :account_logged_in?
  protect_from_forgery { :except => [:destroy] }

  def create
    # videoに紐づいたコメントを取得
    @comments = @video.comments.includes(:user, :viewer, :replies).order(created_at: :desc)
    @reply = @comment.replies.build(reply_params)
    @replies = @comment.replies.includes(:user, :viewer, :replies).order(created_at: :desc)
    # コメント返信したアカウントをセット
    set_replyer_id
    if @reply.save
      flash[:success] = 'コメント返信に成功しました。'
      redirect_to video_url(@comment.video_id)
    else
      flash.now[:danger] = 'コメント返信に失敗しました。'
      render template: 'comments/index'
    end
  end

  def update
    @comments = @video.comments.includes(:user, :viewer, :replies).order(created_at: :desc)
    if @reply.update(reply_params)
      redirect_to video_url(@comment.video_id)
    else
      render template: 'comments/index'
    end
  end

  def destroy
    if @reply.destroy
      flash[:success] = 'コメント返信削除に成功しました。'
      redirect_to video_url(@comment.video_id)
    else
      flash.now[:danger] = 'コメント返信削除に失敗しました。'
      render template: 'comments/index'
    end
  end

  private

  def reply_params
    params.require(:reply).permit(:reply, :video_id, :comment_id, :organization_id).merge(
      comment_id: @comment.id, organization_id: @video.organization_id
    )
  end

  def set_comment_id
    @comment = Comment.find(params[:comment_id])
  end

  def set_reply
    @reply = Reply.find(params[:id])
  end

  # コメント返信したアカウントのidをセット
  def set_replyer_id
    if current_user && (@account == current_user)
      @reply.user_id = current_user.id
    elsif current_viewer && (@account == current_viewer)
      @reply.viewer_id = current_viewer.id
    end
  end

  # コメント返信した動画投稿者、動画視聴者本人のみ許可
  def correct_user_reply_or_correct_viewer_reply
    set_reply
    set_video_id
    if @reply.user_id != current_user&.id || @reply.viewer_id != current_viewer&.id
      redirect_to video_url(@video.id), flash: { danger: '権限がありません' }
    end
  end
end
