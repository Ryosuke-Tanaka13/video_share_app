class QuestionnairesController < ApplicationController
  before_action :set_user

  def new
    @questionnaire = @user.questionnaires.new
  end

  def create
    @questionnaire = @user.questionnaires.new(questionnaire_params)

    if @questionnaire.save
      render json: { redirect: user_questionnaire_path(@user, @questionnaire) }
    else
      render json: { errors: @questionnaire.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @questionnaire = @user.questionnaires.find(params[:id])
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :email, :pre_video_questionnaire, :post_video_questionnaire)
  end
end
