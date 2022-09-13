class CommentsController < ApplicationController
  before_action :set_account
  helper_method :is_login?
  protect_from_forgery :except => [:destroy]
  
  def create
    @video = Video.find(params[:video_id])
    @reply = Reply.new
    # videoに紐づいたコメントを取得
    @comments = @video.comments.order(created_at: :desc)
    # videoに紐づいたコメントを作成
    @comment = @video.comments.build(comment_params)
    # コメント投稿したアカウントをセット
    set_commenter_id
    if @comment.save
      flash[:success] = "コメント投稿に成功しました。"
      redirect_to video_url(@video.id)
    else
      flash.now[:danger] = "コメント投稿に失敗しました。"
      render :index
    end
  end

  def update
    @video= Video.find(params[:video_id])
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      flash[:success] = "コメント編集に成功しました。"
      redirect_to video_url(@video.id)
    else
      flash.now[:danger] = "コメント編集に失敗しました。"
      render :index
    end
  end

  def destroy
    @video = Video.find(params[:video_id])
    @comment = Comment.find(params[:id])
    if @comment.destroy
      flash[:success] = "コメント削除に成功しました。"
      redirect_to video_url(@video.id)
    else
      flash.now[:danger] = "コメント削除に失敗しました。"
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
      if current_user && (@account == current_user)
        @comment.user_id = current_user.id
      elsif current_viewer && (@account == current_viewer)
        @comment.viewer_id = current_viewer.id
      end
    end
    
end
