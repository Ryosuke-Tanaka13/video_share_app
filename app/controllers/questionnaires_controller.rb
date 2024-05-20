class QuestionnairesController < ApplicationController
  before_action :set_user

  def index
    @questionnaires = @user.questionnaires.order(created_at: :desc).page(params[:page]).per(1)
    @current_questionnaire = @questionnaires.first
    @pre_video_questions = JSON.parse(@current_questionnaire.pre_video_questionnaire || '[]')
    @post_video_questions = JSON.parse(@current_questionnaire.post_video_questionnaire || '[]')
  end

  def new
    @questionnaire = @user.questionnaires.new
  end

  def create
    @questionnaire = @user.questionnaires.new(questionnaire_params)
  
    if @questionnaire.save
      render json: { redirect: user_questionnaires_path(@user) } # 修正: pathをindexに
    else
      render json: { errors: @questionnaire.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :email, :pre_video_questionnaire, :post_video_questionnaire)
  end
end
