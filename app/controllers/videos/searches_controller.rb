class Videos::SearchesController < VideosController
  def search
    @search_params = video_search_params
    @organization_videos = Video.includes([:video_blob]).search(@search_params).joins(:user)
    render :index
  end

  private

  def video_search_params
    params.fetch(:search, {}).permit(:title, :created_at_from, :created_at_to, :range, user: [:name])
  end
end
