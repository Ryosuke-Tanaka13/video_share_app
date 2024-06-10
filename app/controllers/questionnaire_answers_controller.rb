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
  
    viewer_id = params[:questionnaire_answer][:viewer_id].presence
    user_id = params[:questionnaire_answer][:user_id].presence
  
    @questionnaire_answer = QuestionnaireAnswer.find_or_initialize_by(video: @video, questionnaire: @questionnaire, viewer_id: viewer_id, user_id: user_id)
  
    pre_video_questionnaire = @questionnaire.pre_video_questionnaire.present? ? JSON.parse(@questionnaire.pre_video_questionnaire) : []
    post_video_questionnaire = @questionnaire.post_video_questionnaire.present? ? JSON.parse(@questionnaire.post_video_questionnaire) : []
  
    @questionnaire_answer.pre_questions = pre_video_questionnaire
    @questionnaire_answer.post_questions = post_video_questionnaire
  
    answers = params[:questionnaire_answer][:answers]
    checkbox_answers = params[:questionnaire_answer][:checkbox_answers]
  
    formatted_answers = {}
    formatted_checkbox_answers = {}
  
    pre_video_questionnaire.each_with_index do |question, index|
      question_id = "q#{index}" # インデックスをベースに一意のキーを生成
  
      if question['type'] == 'checkbox'
        formatted_checkbox_answers[question_id] = [checkbox_answers[index]]
      else
        formatted_answers[question_id] = [answers[index]]

      end
    end
  
    if params[:questionnaire_type] == 'pre_video'
      @questionnaire_answer.pre_answers = formatted_answers.merge(formatted_checkbox_answers)
    else
      @questionnaire_answer.post_answers = formatted_answers.merge(formatted_checkbox_answers)
    end
  
    binding.pry
    if @questionnaire_answer.save
      flash[:success] = "回答が送信されました。"
      redirect_to video_path(@video)
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
    @video = Base64.decode64(params[:video_id].strip)
    @questionnaire_answers_grouped = QuestionnaireAnswer.where(video: @video).group_by { |answer| [answer.viewer_id || "", answer.user_id || ""] }
  end

  def show
    @video = Video.find(params[:video_id])
    @viewer_id = params[:viewer_id]
    @user_id = params[:user_id]
    @questionnaire_answers = QuestionnaireAnswer.where(video_id: @video.id)
    @questionnaire_answers = @questionnaire_answers.where(viewer_id: @viewer_id) unless params[:viewer_id] == "0"
    @questionnaire_answers = @questionnaire_answers.where(user_id: @user_id) unless params[:user_id] == "0"
    @pre_questionnaire_answers = @questionnaire_answers.select { |qa| qa.pre_questions.present? }
    @post_questionnaire_answers = @questionnaire_answers.select { |qa| qa.post_questions.present? }
  end  

  private

  def questionnaire_answer_params
    params.require(:questionnaire_answer).permit(:questionnaire_id, :video_id, :viewer_id, :user_id, :viewer_name, :viewer_email, answers: {}, checkbox_answers: [])
  end

  def set_user_or_viewer
    @user = current_user if user_signed_in?
    @viewer = current_viewer if viewer_signed_in?
  end
end
