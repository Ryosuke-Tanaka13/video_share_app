class Viewers::HiddensController < ApplicationController
  # リファクタリング案
  # → viewers_controller.rb記載のbefore_action :ensure_logged_inをviewers::base.rbに記載し、Viewers::HiddensController < Viewers::Base
  layout 'video_statuses'

  before_action :ensure_logged_in
  before_action :ensure_admin_or_owner
  before_action :ensure_my_organization
  before_action :ensure_admin_for_access_hidden

  def confirm
    set_video
    set_video_status
  end

  def withdraw
    set_video
    set_video_status
    if @video_status.update(is_valid: false)
      flash[:success] = '削除しました。'
      redirect_to video_statuses_url(@video)
    else
      render :confirm
    end
  end

  private

  def set_video
    @video = Video.find(params[:video_id])
  end

  def set_video_status
    @video_status = VideoStatus.find(params[:id])
  end

  # before_actionとして記載(いずれも、hiddensコントローラでの独自定義)
  def ensure_admin_or_owner
    if !current_system_admin? && (current_user&.role != 'owner')
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  def ensure_my_organization
    if current_user && (current_user.organization_id != Video.find(params[:video_id]).organization_id)
      flash[:danger] = '権限がありません。'
      redirect_to videos_url(organization_id: current_user.organization_id)
    end
  end

  def ensure_admin_for_access_hidden
    set_video_status
    if current_system_admin.nil? && @video_status.not_valid?
      flash[:danger] = 'すでに削除された視聴状況です。'
      redirect_back(fallback_location: root_url)
    end
  end
end
