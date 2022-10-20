class VideosController < ApplicationController
  include CommentReply
  before_action :set_account
  helper_method :account_logged_in?
  
  def show
    @video = Video.find(params[:id])
    @comment = Comment.new
    @reply = Reply.new
    # 新着順で表示
    @comments = @video.comments.includes(:user, :viewer, :replies).order(created_at: :desc)
  end

end