class CommentsController < ApplicationController
  include CommentReply
  before_action :set_account
  before_action :ensure_system_admin_or_user_or_viewer
  before_action :correct_admin_or_user_or_viewer_comment, only: %i[update destroy]
  protect_from_forgery { :except => [:destroy] }

  def create
    set_video_id
    @reply = Reply.new
    # videoに紐づいたコメントを取得
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
    # videoに紐づいたコメントを作成
    @comment = @video.comments.build(comment_params)
    # コメント投稿したアカウントをセット
    set_commenter_id
    if @comment.save
      flash[:success] = 'コメント投稿に成功しました。'
      redirect_to video_url(@video.id)
    else
      flash.now[:danger] = 'コメント投稿に失敗しました。'
      render :index
    end
  end

  def update
    @reply = Reply.new
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      redirect_to video_url(@video.id)
    else
      flash.now[:danger] = 'コメント編集に失敗しました。'
      render :index
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.destroy
      flash[:success] = 'コメント削除に成功しました。'
      redirect_to video_url(@video.id)
    else
      flash.now[:danger] = 'コメント削除に失敗しました。'
      render :index
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:comment, :video_id, :organization_id).merge(
      organization_id: @video.organization_id
    )
  end

  # コメントしたアカウントidをセット
  def set_commenter_id
    if current_system_admin && (@account == current_system_admin)
      @comment.system_admin_id = current_system_admin.id
    elsif current_user && (@account == current_user)
      @comment.user_id = current_user.id
    elsif current_viewer && (@account == current_viewer)
      @comment.viewer_id = current_viewer.id
    end
  end

  # コメントしたシステム管理者、動画投稿者、動画視聴者本人のみ許可
  def correct_admin_or_user_or_viewer_comment
    @comment = Comment.find(params[:id])
    set_video_id
    if @comment.system_admin_id != current_system_admin&.id || @comment.user_id != current_user&.id || @comment.viewer_id != current_viewer&.id
      redirect_to video_url(@video.id), flash: { danger: '権限がありません' }
    end
  end
end
