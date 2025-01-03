require 'rails_helper'

RSpec.describe "AwsS3s", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/aws_s3/new"
      expect(response).to have_http_status(:success)
    end
  end

end
