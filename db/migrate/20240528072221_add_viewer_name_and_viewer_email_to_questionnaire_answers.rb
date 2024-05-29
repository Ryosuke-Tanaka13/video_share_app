class AddViewerNameAndViewerEmailToQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaire_answers, :viewer_name, :string
    add_column :questionnaire_answers, :viewer_email, :string
  end
end
