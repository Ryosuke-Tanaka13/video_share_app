class Videos::SearchesController < VideosController
  def search
    @search_params = video_search_params
    if current_system_admin.present?
      @organization_videos = Video.includes([:video_blob]).for_system_admin(session[:organization_id]).search(@search_params)
    elsif current_user.present?
      @organization_videos = Video.includes([:video_blob]).for_user(current_user).available.search(@search_params)
    elsif current_viewer.present?
      @organization_videos = Video.includes([:video_blob]).for_user(session[:organization_id]).available.search(@search_params)
    end
    render :index
  end

  private

  def video_search_params
    params.fetch(:search, {}).permit(:title_like, :open_period_from, :open_period_to, :range, :user_name)
  end
end
