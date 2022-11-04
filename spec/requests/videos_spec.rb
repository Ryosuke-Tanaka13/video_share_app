require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  describe 'GET /show' do
    it 'returns http success' do
      get '/videos/show'
      expect(response).to have_http_status(:success)
    end
  end
end
