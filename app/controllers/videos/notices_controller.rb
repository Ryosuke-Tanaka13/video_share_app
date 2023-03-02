class Videos::NoticesController < VideosController
  before_action :ensure_set_video_expire
  skip_before_action :ensure_logged_in

  def expire; end

  private

  def ensure_set_video_expire
    redirect_to root_url if !Video.find(params[:id]).open_period || (Video.find(params[:id]).open_period&.>Time.current)
  end
end
