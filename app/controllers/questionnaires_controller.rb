class QuestionnairesController < ApplicationController
  before_action :set_user
  before_action :set_questionnaire, only: [:show, :edit, :update, :destroy, :apply]

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
      save_questionnaire_items(@questionnaire)
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
      update_questionnaire_items(@questionnaire)
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

  def save_questionnaire_items(questionnaire)
    pre_video_questions = parse_questions(questionnaire.pre_video_questionnaire)
    post_video_questions = parse_questions(questionnaire.post_video_questionnaire)
  
    # 前動画質問に対する処理
    pre_video_questions.each do |question|
      item = QuestionnaireItem.create(
        questionnaire: questionnaire,
        pre_question_text: question['text'],
        pre_question_type: question['type'],
        pre_options: question['answers']
      )
      answer = QuestionnaireAnswer.new(
        questionnaire_item: item,
        questionnaire: questionnaire,
        user_id: questionnaire.user_id,
        pre_answers: []
      )
      if answer.save
        puts "QuestionnaireAnswer saved successfully."
      else
        puts "Failed to save QuestionnaireAnswer: #{answer.errors.full_messages.join(", ")}"
      end
    end
  
    # 後動画質問に対する処理
    post_video_questions.each do |question|
      item = QuestionnaireItem.create(
        questionnaire: questionnaire,
        post_question_text: question['text'],
        post_question_type: question['type'],
        post_options: question['answers']
      )
      answer = QuestionnaireAnswer.new(
        questionnaire_item: item,
        questionnaire: questionnaire,
        user_id: questionnaire.user_id,
        post_answers: []
      )
      if answer.save
        puts "QuestionnaireAnswer saved successfully."
      else
        puts "Failed to save QuestionnaireAnswer: #{answer.errors.full_messages.join(", ")}"
      end
    end
  end  

  def update_questionnaire_items(questionnaire)
    # 既存の質問項目を削除する前に関連する回答を削除
    questionnaire.questionnaire_items.each do |item|
      item.questionnaire_answers.destroy_all
    end
    questionnaire.questionnaire_items.destroy_all
    save_questionnaire_items(questionnaire)
  end
end
