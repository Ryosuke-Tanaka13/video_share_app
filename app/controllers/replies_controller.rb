class RepliesController < ApplicationController
  before_action :set_account
  helper_method :is_login?
  protect_from_forgery :except => [:destroy]

  def create
    @video = Video.find(params[:video_id])
    @comment = Comment.find(params[:comment_id])
    # videoに紐づいたコメントを取得
    @comments = @video.comments.order(created_at: :desc)
    @reply = @comment.replies.build(reply_params)
    @replies = @comment.replies.order(created_at: :desc)
    # コメント返信したアカウントをセット
    set_replyer_id
    if @reply.save
      flash[:success] = "コメント返信に成功しました。"
      redirect_to video_url(@comment.video_id)
    else
      flash.now[:danger] = "コメント返信に失敗しました。"
      render template: "comments/index"
    end
  end

  def update
    @comment = Comment.find(params[:comment_id])
    @reply = Reply.find(params[:id])
    if @reply.update(eply_params)
      flash[:success] = "コメント返信編集に成功しました。"
      redirect_to video_url(@comment.video_id)
    else
      flash.now[:danger] = "コメント返信編集に失敗しました。"
      render template: "comments/index"
    end
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    @reply = Reply.find(params[:id])
    if @reply.destroy
      flash[:success] = "コメント返信削除に成功しました。"
      redirect_to video_url(@comment.video_id)
    else
      flash.now[:danger] = "コメント削除返信に失敗しました。"
      render template: "comments/index"
    end
  end

  private
    def reply_params
      params.require(:reply).permit(:reply, :video_id, :comment_id, :organization_id).merge(
        comment_id: @comment.id, organization_id: @video.organization_id
      )
    end

    # コメント返信したアカウントのidをセット
    def set_replyer_id
      if current_user && (@account == current_user)
        @reply.user_id = current_user.id
      elsif current_viewer && (@account == current_viewer)
        @reply.viewer_id = current_viewer.id
      end
    end

end