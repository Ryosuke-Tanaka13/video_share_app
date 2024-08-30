class QuestionnaireAnswersController < ApplicationController
  before_action :set_user_or_viewer, only: %i[create index destroy]
  before_action :ensure_logged_in
  before_action :set_questionnaire_answer, only: %i[destroy]

  def create
    video_id = params[:questionnaire_answer][:video_id]

    @video = Video.find(video_id)
    viewer_id = params[:questionnaire_answer][:viewer_id].presence
    user_id = params[:questionnaire_answer][:user_id].presence

    @questionnaire_answer = QuestionnaireAnswer.find_or_initialize_by(video_id: @video.id, viewer_id: viewer_id, user_id: user_id)
    if current_user.present?
      @questionnaire_answer.viewer_name = current_user.name
      @questionnaire_answer.viewer_email = current_user.email
    elsif current_viewer.present?
      @questionnaire_answer.viewer_name = current_viewer.name
      @questionnaire_answer.viewer_email = current_viewer.email
    end

    params[:questionnaire_answer][:answers]&.each do |item_id, answer|
      item_id = item_id.to_i # item_id を整数に変換
      item = QuestionnaireItem.find_by(id: item_id, video_id: video_id)
      if item.nil?
        flash[:error] = 'Questionnaire item not found'
        redirect_to video_path(@video)
        return
      end

      @questionnaire_answer.questionnaire_item_id = item.id

      # ハッシュとして初期化されていることを確認する
      @questionnaire_answer.pre_answers = {} unless @questionnaire_answer.pre_answers.kind_of?(Hash)
      @questionnaire_answer.post_answers = {} unless @questionnaire_answer.post_answers.kind_of?(Hash)

      # 必須質問の回答が空でないかチェック
      if item.required && (answer.blank? || (answer.kind_of?(Array) && answer.all?(&:blank?)))
        flash.now[:danger] = '回答に不備があります。※は必須項目です。'
        # 必須質問が空の場合、元の質問情報を再取得してレンダー
        if params[:questionnaire_type] == 'pre_video'
          @pre_video_questions = @video.questionnaire_items.where.not(pre_question_text: nil)
          render 'videos/_popup_before', locals: { video: @video, pre_video_questions: @pre_video_questions } and return
        else
          @post_video_questions = @video.questionnaire_items.where.not(post_question_text: nil)
          render 'videos/_popup_after', locals: { video: @video, post_video_questions: @post_video_questions } and return
        end
      end

      if params[:questionnaire_type] == 'pre_video'
        @questionnaire_answer.pre_answers[item_id.to_s] = answer
      else
        @questionnaire_answer.post_answers[item_id.to_s] = answer
      end
    end
    
    if @questionnaire_answer.save
      flash[:success] = '回答が送信されました。'
      redirect_to video_path(@video, answered: true)
    else
      flash.now[:danger] = '回答の送信に失敗しました。'
      flash.now[:error_messages] = @questionnaire_answer.errors.full_messages.join(', ')
      if params[:questionnaire_type] == 'pre_video'
        @pre_video_questions = @video.questionnaire_items.where.not(pre_question_text: nil)
        render 'videos/_popup_before', locals: { video: @video, questionnaire: @questionnaire, pre_video_questions: @pre_video_questions }
      else
        @post_video_questions = @video.questionnaire_items.where.not(post_question_text: nil)
        render 'videos/_popup_after', locals: { video: @video, questionnaire: @questionnaire, post_video_questions: @post_video_questions }
      end
    end
  end

  def index
    @video_id = Base64.decode64(params[:video_id].strip)
    @video = Video.find(@video_id)
    @questionnaire_answers_grouped = QuestionnaireAnswer.where(video_id: @video_id).select { |answer| answer.pre_answers.present? || answer.post_answers.present? }
      .group_by { |answer| [answer.viewer_id || '', answer.user_id || ''] }
  end

  def show
    @video_id = Base64.decode64(params[:video_id].strip)
    @video = Video.find(@video_id)
    @viewer_id = params[:viewer_id]
    @user_id = params[:user_id]

    # モデルのメソッドを使用して回答を取得
    @questionnaire_answers = QuestionnaireAnswer.for_video_and_user(
      video_id: @video.id,
      viewer_id: @viewer_id,
      user_id: @user_id
    )

    # 動画視聴前動画と視聴後動画の回答を取得
    @pre_questionnaire_answers = QuestionnaireAnswer.pre_video_answers(@questionnaire_answers)
    @post_questionnaire_answers = QuestionnaireAnswer.post_video_answers(@questionnaire_answers)
  end

  def destroy
    if @questionnaire_answer.destroy
      flash[:success] = "回答が削除されました。"
    else
      flash[:danger] = "回答の削除に失敗しました。"
    end
    redirect_to video_questionnaire_answers_url
  end

  private

  def questionnaire_answer_params
    params.require(:questionnaire_answer).permit(:questionnaire_id, :video_id, :viewer_id, :user_id, :viewer_name, :viewer_email,
      answers: {})
  end

  def set_user_or_viewer
    @user = current_user if user_signed_in?
    @viewer = current_viewer if viewer_signed_in?
  end

  def set_questionnaire_answer
    @questionnaire_answer = QuestionnaireAnswer.find(params[:id])
  end

  def set_user
    @user = current_user if current_user.present?
  end
end
