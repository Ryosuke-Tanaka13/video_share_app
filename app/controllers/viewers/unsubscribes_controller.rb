class Viewers::UnsubscribesController < ApplicationController
  before_action :correct_viewer
  before_action :set_viewer
  layout 'viewers_auth'
  
  def show
  end

  def update
    @viewer.update(is_valid: false)
    reset_session
    flash[:notice] = "退会処理が完了しました。"
    redirect_to root_path
  end

    private

    def set_viewer
      @viewer = Viewer.find(params[:id])
    end
  
  end
  