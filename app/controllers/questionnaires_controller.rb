class QuestionnairesController < ApplicationController
  before_action :set_user
  before_action :set_questionnaire, only: [:show, :edit, :update, :destroy]

  def index
    @questionnaires = @user.questionnaires.order(created_at: :desc).page(params[:page]).per(1) # アンケート自体のページネーション
    @current_questionnaire = @questionnaires.first
    if @current_questionnaire
      @pre_video_questions = JSON.parse(@current_questionnaire.pre_video_questionnaire || '[]')
      @post_video_questions = JSON.parse(@current_questionnaire.post_video_questionnaire || '[]')
    end
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
  
  def edit
    @questionnaire = @user.questionnaires.find(params[:id])
  end  

  def update
    @questionnaire = @user.questionnaires.find(params[:id])
  
    if @questionnaire.update(questionnaire_params)
      render json: { redirect: edit_user_questionnaire_path(@user, @questionnaire) }
      flash[:success] = "アンケートが更新されました。"
    else
      render json: { errors: @questionnaire.errors.full_messages }, status: :unprocessable_entity
      flash[:danger] = "アンケートの更新に失敗しました。"
    end
  end
  

  def destroy
    @questionnaire.destroy
    redirect_to user_questionnaires_path(@user)
    flash[:success] = 'アンケートが削除されました。'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_questionnaire
    @questionnaire = @user.questionnaires.find(params[:id])
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :email, :pre_video_questionnaire, :post_video_questionnaire)
  end
end
