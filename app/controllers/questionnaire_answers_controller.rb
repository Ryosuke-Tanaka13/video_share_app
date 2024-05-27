class QuestionnaireAnswersController < ApplicationController
  def create
    @questionnaire_answer = QuestionnaireAnswer.new(questionnaire_answer_params)
    @questionnaire_answer.viewer = current_viewer

    if @questionnaire_answer.save
      redirect_to @questionnaire_answer.video, notice: 'アンケートの回答が保存されました。'
    else
      redirect_to @questionnaire_answer.video, alert: 'アンケートの回答に失敗しました。'
    end
  end

  def index
    @video = Video.find(params[:video_id])
    @questionnaire_answers = @video.questionnaire_answers.includes(:viewer, :questionnaire)
  end

  private

  def questionnaire_answer_params
    params.require(:questionnaire_answer).permit(:questionnaire_id, :video_id, answers: {})
  end
end
