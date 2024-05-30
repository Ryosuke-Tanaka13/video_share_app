class QuestionnaireAnswersController < ApplicationController
  before_action :set_user_or_viewer, only: %i[create index]

  def create
    video_id = params[:questionnaire_answer][:video_id]

    if video_id.nil?
      flash[:error] = "Video not found"
      redirect_to root_path
      return
    end

    @video = Video.find(video_id)
    @questionnaire = Questionnaire.find(params[:questionnaire_answer][:questionnaire_id])

    @questionnaire_answer = QuestionnaireAnswer.new(questionnaire_answer_params)
    @questionnaire_answer.video = @video
    @questionnaire_answer.questionnaire = @questionnaire
    @questionnaire_answer.viewer_id = params[:questionnaire_answer][:viewer_id].presence
    @questionnaire_answer.user_id = params[:questionnaire_answer][:user_id].presence

    if @questionnaire_answer.save
      flash[:success] = "回答が送信されました。"
      redirect_to @video
    else
      flash.now[:danger] = "回答の送信に失敗しました。"
      flash.now[:error_messages] = @questionnaire_answer.errors.full_messages.join(", ")
      respond_to do |format|
        format.html { render 'videos/_popup_before', locals: { video: @video, questionnaire: @questionnaire, pre_video_questions: JSON.parse(@questionnaire.pre_video_questionnaire) } }
        format.js { render 'videos/_popup_before', locals: { video: @video, questionnaire: @questionnaire, pre_video_questions: JSON.parse(@questionnaire.pre_video_questionnaire) } }
      end
    end
  end

  def index
    @questionnaire_answers = QuestionnaireAnswer.includes(:video, :viewer, :user).all
    @video = Base64.decode64(params[:video_id].strip)
  end

  def show
    @questionnaire_answer = QuestionnaireAnswer.find(params[:id])
    respond_to do |format|
      format.html
      format.js  
    end
  end

  private

  def questionnaire_answer_params
    params.require(:questionnaire_answer).permit(:questionnaire_id, :video_id, :viewer_id, :user_id, :viewer_name, :viewer_email, answers: [])
  end

  def set_user_or_viewer
    @user = current_user if user_signed_in?
    @viewer = current_viewer if viewer_signed_in?
  end
end
