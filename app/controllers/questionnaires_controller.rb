class QuestionnairesController < ApplicationController
  before_action :set_organization
  def new
  end

  private
    def set_organization
      @organization = Organization.find(params[:organization_id])
    end
end
