class QuestionnairesController < ApplicationController
  before_action :set_user
  before_action :set_questionnaire, only: [:show, :edit, :update, :destroy, :apply]
  before_action :ensure_logged_in
  before_action :correct_user_id?

  def index
    @questionnaires = @user.questionnaires.order(updated_at: :desc).page(params[:page]).per(1)
    @current_questionnaire = @questionnaires.first
    if @current_questionnaire
      @pre_video_questions = parse_questions(@current_questionnaire.pre_video_questionnaire)
      @post_video_questions = parse_questions(@current_questionnaire.post_video_questionnaire)
    end
  end

  def new
    @questionnaire = @user.questionnaires.new
  end

  def create
    @questionnaire = @user.questionnaires.new(questionnaire_params)
    if @questionnaire.save
      render json: { redirect: user_questionnaires_path(@user) }
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
      flash[:success] = "アンケートが更新されました。"
      render json: {
        redirect: user_questionnaires_path(
          @user,
          apply: params[:apply],
          type: params[:type],
          popup_before_video: params[:popup_before_video],
          popup_after_video: params[:popup_after_video]
        )
      }
    else
      render json: {
        errors: @questionnaire.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @questionnaire.destroy
    redirect_to user_questionnaires_path(@user)
    flash[:success] = 'アンケートが削除されました。'
  end

  def apply
    @questionnaire = Questionnaire.find(params[:id])
    respond_to do |format|
      format.json { render json: { id: @questionnaire.id, name: @questionnaire.name } }
    end
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

  def parse_questions(questionnaire_data)
    if questionnaire_data.is_a?(String) && questionnaire_data.strip.empty?
      []
    elsif questionnaire_data.is_a?(String)
      JSON.parse(questionnaire_data)
    else
      questionnaire_data || []
    end
  end

  def correct_user_id?
    unless current_user == User.find(params[:user_id])
      flash[:danger] = '権限がありません。'
      redirect_to root_url
    end
  end
end
