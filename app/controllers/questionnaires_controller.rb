class QuestionnairesController < ApplicationController
  before_action :set_user
  before_action :set_questionnaire, only: %i[show edit update destroy apply]
  before_action :ensure_logged_in
  before_action :correct_user_id?

  def index
    @questionnaires = @user.questionnaires.order(updated_at: :desc).page(params[:page]).per(1)
    @current_questionnaire = @questionnaires.first
    # 現在のアンケートが存在する場合、動画視聴前と視聴後のアンケートの質問を解析して取得
    if @current_questionnaire
      @pre_video_questions = parse_questions(@current_questionnaire.pre_video_questionnaire)
      @post_video_questions = parse_questions(@current_questionnaire.post_video_questionnaire)
    end
  end

  def new
    @questionnaire = @user.questionnaires.new
  end

  def create
    if params[:questionnaire][:pre_video_questionnaire] == '[]' && params[:questionnaire][:post_video_questionnaire] == '[]'
      render json: { redirect: new_user_questionnaire_path(@user) }
      flash[:danger] = 'エラーが発生しました。質問を入力してください'
      return
    end

    @questionnaire = @user.questionnaires.new(questionnaire_params)
    if @questionnaire.save
      render json: { redirect: user_questionnaires_path(@user) }
    else
      render json: { redirect: new_user_questionnaire_path(@user) }
      flash[:danger] = 'エラーが発生しました。質問を入力してください'
    end
  end

  def edit
    @questionnaire = @user.questionnaires.find(params[:id])
  end

  def update
    @questionnaire = @user.questionnaires.find(params[:id])
    if @questionnaire.update(questionnaire_params)
      flash[:success] = 'アンケートが更新されました。'
      render json: {
        redirect: user_questionnaires_path(
          @user,
          apply:              params[:apply],
          type:               params[:type],
          popup_before_video: params[:popup_before_video],
          popup_after_video:  params[:popup_after_video]
        )
      }
    else
      render json: { redirect: edit_user_questionnaire_path(@user, @questionnaire) }
      flash[:danger] = '編集内容が無効です。質問を入力してください'
    end
  end

  def destroy
    puts "Found questionnaire: #{@questionnaire.inspect}"
    @questionnaire.destroy
    redirect_to user_questionnaires_path(@user)
    flash[:success] = 'アンケートが削除されました。'
  end

  def apply
    # 選択されたアンケートを適用する
    @questionnaire = Questionnaire.find(params[:id])
    # JSON形式でアンケートのIDと名前を返す
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
    # アンケートデータが文字列でかつ空白文字のみの場合、空の配列を返す
    if questionnaire_data.kind_of?(String) && questionnaire_data.strip.empty?
      []
    # アンケートデータが文字列の場合、JSON形式で解析して配列として返す
    elsif questionnaire_data.kind_of?(String)
      JSON.parse(questionnaire_data)
    # アンケートデータが配列の場合、そのまま返す。データがnilの場合は空の配列を返す
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
