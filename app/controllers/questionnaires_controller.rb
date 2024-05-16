class QuestionnairesController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @questionnaire = @user.questionnaires.new
  end

  def create
    @user = User.find(params[:user_id])
    @questionnaire = @user.questionnaires.new(questionnaire_params)

    if @questionnaire.save
      render json: { redirect: user_questionnaire_path(@user, @questionnaire) }
    else
      render json: { errors: @questionnaire.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :email, :pre_video_questionnaire, :post_video_questionnaire)
  end
end
