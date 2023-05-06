class Viewers::VideoStatusesController < ApplicationController
  # リファクタリング案
  # → viewers_controller.rb記載のbefore_action :ensure_logged_inと、ensure_admin_or_user, ensure_adminをviewers::base.rbに記載し、Viewers::VideoStatusesController < Viewers::Base
  include Viewers::VideoStatusesHelper
  layout 'video_statuses'

  before_action :ensure_logged_in
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_viewer, only: %i[update]
  before_action :ensure_my_organization, only: %i[index update]
  before_action :ensure_admin, only: %i[destroy]

  def index
    set_video
    @viewers = if current_user
                 Viewer.viewer_has(@video.organization.id).subscribed
               elsif current_system_admin
                 Viewer.viewer_has(@video.organization.id)
               end
    # 視聴完了している視聴者
    @complete_viewers = @viewers.completely_watched(@video.id)
    # 視聴完了している視聴者の割合
    @complete_viewers_rate = (@complete_viewers.count / @viewers.count.to_f.to_f * 100).round(0) if @viewers.exists?
    # 視聴状況が作成されていない場合は、視聴率が0.0%のインスタンスを生成
    set_video_statuses
    # 視聴率が100.0%未満のインスタンスをグラフ表示
    make_graph
  end

  def update
    set_video_status
    if @video_status.correct_latest_start_point?(params[:video_status][:latest_start_point].to_f) \
      && @video_status.correct_latest_end_point?(params[:video_status][:latest_end_point].to_f)
      @video_status.update!(video_status_params)
      if completely_watched?
        @video_status.update!(watched_ratio: 100.0, watched_at: Time.current)
      else
        @video_status.update!(watched_ratio: caluculate_watched_ratio)
      end
    end
  end

  def destroy
    @video = Video.find(params[:video_id]) if @video.blank?
    set_video_status
    @video_status.destroy!
    flash[:success] = '削除しました。'
    redirect_to video_statuses_url(@video)
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end

  def set_video_status
    @video_status = VideoStatus.find(params[:id])
  end

  def video_status_params
    params.require(:video_status).permit(:total_time, :latest_end_point, :video_id, :viewer_id)
  end

  def set_video_statuses
    ActiveRecord::Base.transaction do
      @viewers.each do |viewer|
        unless viewer.video_statuses.find_by(video_id: @video.id).present?
          viewer.video_statuses.create!(video_id: @video.id, watched_ratio: 0.0)
        end
      end
    end
  end

  def make_graph
    @side = []
    @vertical = []

    @viewers.each do |viewer|
      @video_status = viewer.video_statuses.find_by(video_id: @video.id)
      if @video_status.not_completely_watched?
        @side.push(viewer.name)
        @vertical.push(@video_status.watched_ratio)
      end
    end
  end

  # 視聴率を計算し戻り値を返す
  def caluculate_watched_ratio
    # 下記の数字の例は、左が再生完了地点、右が動画の総時間。(最後まで再生した場合でも、再生完了時点と動画の総時間はぴったりイコールにはならない。)
    # 12.5と12.8などの場合 → 12/12*100 → 視聴率は100.0%
    if params[:video_status][:latest_end_point].to_i == params[:video_status][:total_time].to_i
      ((params[:video_status][:latest_end_point].to_i / params[:video_status][:total_time].to_i).to_f).round(2) * 100
    # 6.5と12.8などの場合 → 6/12*100 → 50.0%
    elsif (params[:video_status][:latest_end_point].to_i < params[:video_status][:total_time].to_i) \
      && ((params[:video_status][:latest_end_point].to_f - params[:video_status][:total_time].to_f) > 1.0)
      ((params[:video_status][:latest_end_point].to_f).floor(0) / (params[:video_status][:total_time].to_f).floor(0).to_f).round(2) * 100
    # 11.9と12.8などの場合(再生完了時点が1秒未満の誤差で動画の総時間に満たない場合) → 12/12*100 → 100.0%
    elsif (params[:video_status][:latest_end_point].to_i < params[:video_status][:total_time].to_i) \
      && ((params[:video_status][:latest_end_point].to_f - params[:video_status][:total_time].to_f) < 1.0)
      ((params[:video_status][:latest_end_point].to_f).ceil(0) / (params[:video_status][:total_time].to_f).floor(0).to_f).round(2) * 100
    end
  end

  # 最後まで視聴が完了していればtrueを返す
  def completely_watched?
    return true if caluculate_watched_ratio == 100

    false
  end

  # before_actionとして記載(いずれも、video_statusesコントローラでの独自定義)
  def ensure_viewer
    unless current_viewer
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  def ensure_my_organization
    if current_user
      if current_user.organization_id != Video.find(params[:id]).organization_id
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      end
    elsif current_viewer
      if current_viewer.ensure_member(Video.find(params[:video_status][:video_id]).organization_id).empty?
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end
end
