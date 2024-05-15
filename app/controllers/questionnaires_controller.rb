class QuestionnairesController < ApplicationController
  before_action :set_user
  def new
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end
end
