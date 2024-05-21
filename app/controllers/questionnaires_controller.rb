class QuestionnairesController < ApplicationController
  before_action :set_user
  before_action :set_questionnaire, only: [:show, :edit, :update, :destroy]

  def index
    @questionnaires = @user.questionnaires.order(created_at: :desc).page(params[:page]).per(1)
    @current_questionnaire = @questionnaires.first
    if @current_questionnaire
      @pre_video_questions = Kaminari.paginate_array(JSON.parse(@current_questionnaire.pre_video_questionnaire || '[]')).page(params[:pre_page]).per(1)
      @post_video_questions = Kaminari.paginate_array(JSON.parse(@current_questionnaire.post_video_questionnaire || '[]')).page(params[:post_page]).per(1)
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
    if @questionnaire.update(questionnaire_params)
      redirect_to user_questionnaires_path(@user), notice: 'アンケートが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @questionnaire.destroy
    redirect_to user_questionnaires_path(@user), notice: 'アンケートが削除されました。'
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
