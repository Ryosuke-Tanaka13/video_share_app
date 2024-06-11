class ModifyQuestionnaireAnswers < ActiveRecord::Migration[6.1]
  def change
    change_table :questionnaire_answers, bulk: true do |t|
      t.change :pre_answers, :json
      t.change :post_answers, :json
    end

    remove_column :questionnaire_answers, :answers, :json
    remove_column :questionnaire_answers, :pre_questions, :text
    remove_column :questionnaire_answers, :post_questions, :text
    remove_column :questionnaire_answers, :checkbox_pre_answers, :json
    remove_column :questionnaire_answers, :checkbox_post_answers, :json
  end
end
