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
    viewer_id = params[:questionnaire_answer][:viewer_id].presence
    user_id = params[:questionnaire_answer][:user_id].presence

    # 既存のQuestionnaireAnswerを検索する
    @questionnaire_answer = QuestionnaireAnswer.find_or_initialize_by(video_id: @video.id, viewer_id: viewer_id, user_id: user_id)

    # pre_answers および post_answers をハッシュとして初期化
    @questionnaire_answer.pre_answers = (@questionnaire_answer.pre_answers.is_a?(Hash) ? @questionnaire_answer.pre_answers : {}).with_indifferent_access
    @questionnaire_answer.post_answers = (@questionnaire_answer.post_answers.is_a?(Hash) ? @questionnaire_answer.post_answers : {}).with_indifferent_access
    @questionnaire_answer.viewer_name = params[:questionnaire_answer][:viewer_name] unless params[:questionnaire_answer][:viewer_name].nil?
    @questionnaire_answer.viewer_email = params[:questionnaire_answer][:viewer_email] unless params[:questionnaire_answer][:viewer_email].nil?
    
    # 回答を追加
    params[:questionnaire_answer][:answers]&.each do |item_id, answer|
      item_id = item_id.to_i # item_id を整数に変換
      if params[:questionnaire_type] == 'pre_video'
        @questionnaire_answer.pre_answers[item_id.to_s] = answer
      else
        @questionnaire_answer.post_answers[item_id.to_s] = answer
      end
    end

    if @questionnaire_answer.save
      flash[:success] = "回答が送信されました。"
      redirect_to video_path(@video)
    else
      flash[:danger] = "回答の送信に失敗しました。"
      puts @questionnaire_answer.errors.full_messages
      redirect_to video_path(@video)
    end
  end

  def index
    @video_id = Base64.decode64(params[:video_id].strip)
    @video = Video.find(@video_id)
    @questionnaire_answers_grouped = QuestionnaireAnswer.where(video_id: @video_id)
      .group_by { |answer| [answer.viewer_id || "", answer.user_id || ""] }
  end

  def show
    @video_id = Base64.decode64(params[:video_id].strip)
    @video = Video.find(@video_id)
    @viewer_id = params[:viewer_id]
    @user_id = params[:user_id]
    @questionnaire_answers = QuestionnaireAnswer.where(video_id: @video.id)
    @questionnaire_answers = @questionnaire_answers.where(viewer_id: @viewer_id) unless params[:viewer_id] == "0"
    @questionnaire_answers = @questionnaire_answers.where(user_id: @user_id) unless params[:user_id] == "0"
    @pre_questionnaire_answers = @questionnaire_answers.select { |qa| qa.pre_answers.present? }
    @post_questionnaire_answers = @questionnaire_answers.select { |qa| qa.post_answers.present? }
  end  

  private

  def questionnaire_answer_params
    params.require(:questionnaire_answer).permit(:questionnaire_id, :video_id, :viewer_id, :user_id, :viewer_name, :viewer_email, answers: {})
  end

  def set_user_or_viewer
    @user = current_user if user_signed_in?
    @viewer = current_viewer if viewer_signed_in?
  end
end
