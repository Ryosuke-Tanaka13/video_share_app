class QuestionnairesController < ApplicationController
    def new
        @questionnaire = Questionnaire.new
        @questionnaire_item = @questionnaire.questionnaire_items.new
    end

    def create
        @questionnaire = questionnaire.new(questionnaire_params)
        if @questionnaire.save
            redirect_to root_path
        else
            render "new"
        end
    end

    def edit

    end

    def show
    end

    def index
        @questionnaires = Questionnaire.all
    end


    private

    def questionnaire_params
        params.require(:questionnaire).permit(:title, :organization_id, :use_at, questionnaire_item_attributes: [:questionnaire_id, :name, :type, :order_number])
    end



end
