class SystemAdminsController < ApplicationController
  before_action :logged_in_system_admin
  before_action :set_system_admin, only: %i[show edit update]

  def show; end

  def edit; end

  def update
    if @system_admin.update(system_admin_params)
      flash[:success] = '更新しました'
      redirect_to system_admin_url
    else
      render 'edit'
    end
  end

  private

  def system_admin_params
    params.require(:system_admin).permit(:name, :email)
  end

  def set_system_admin
    @system_admin = SystemAdmin.find(params[:id])
  end
end
