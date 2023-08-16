require 'rails_helper'

RSpec.describe "Organizations::Payments", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/organizations/payments/new"
      expect(response).to have_http_status(:success)
    end
  end

end
