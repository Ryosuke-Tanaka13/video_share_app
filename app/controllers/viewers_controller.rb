class ViewersController < ApplicationController
  before_action :set_viewer, except: %i[index new create]

  def index
    @viewers = Viewer.all
  end

  def new
    @viewer = Viewer.new
  end

  def create
    @viewer = Viewer.new(viewer_params)
    if @viewer.save
      flash[:success] = "#{@viewer.name}の作成に成功しました"
      redirect_to viewers_url
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @viewer.update(viewer_params)
      flash[:success] = '更新しました'
      redirect_to viewers_url
    else
      render 'edit'
    end
  end

  def destroy
    @viewer.destroy!
    flash[:danger] = "#{@viewer.name}のユーザー情報を削除しました"
    redirect_to viewers_url
  end

  private

  def viewer_params
    params.require(:viewer).permit(:name, :email)
  end

  def set_viewer
    @viewer = Viewer.find(params[:id])
  end
end
