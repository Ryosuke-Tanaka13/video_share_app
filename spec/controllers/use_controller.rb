# spec/controllers/use_controller_spec.rb
require 'rails_helper'

RSpec.describe UseController, type: :controller do
  # GET #index
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  # GET #top
  describe 'GET #top' do
    it 'returns http success' do
      get :top
      expect(response).to have_http_status(:success)
    end
  end

  # GET #privacy_policy
  describe 'GET #privacy_policy' do
    it 'returns http success' do
      get :privacy_policy
      expect(response).to have_http_status(:success)
    end
  end
end
