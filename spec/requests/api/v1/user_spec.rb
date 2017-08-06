require 'rails_helper'

RSpec.describe 'Users AIP', type: :request do
  let!(:user) { create(:user) }
  let(:user_id) { user.id }
  before { host! 'api.taskmanagerapi.dev' }

  describe "GET /users/:id" do
    before do
      headers = { 'Accept' => 'application/vnd.taskmanager.v1' }
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context 'When user exists' do
      it 'Returns the user' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:id]).to eq(user_id)
      end

      it 'Returns the status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'When user does not exist' do
      let(:user_id) { 10000 }
      it 'Returns the status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /users' do
    before do
      headers = { 'Accept' => 'application/vnd.taskmanagerapi.v1' }
      post '/users', params: { user: user_params }, headers: headers
    end

    context 'When the request params are valid' do
      let(:user_params) { attributes_for(:user) }

      it 'Returns the status code 201' do
        expect(response).to have_http_status(201)        
      end

      it 'Returns the JSON data for created user' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq(user_params[:email])
      end
    end

    context 'When the request params are invalid' do
      let(:user_params) { attributes_for(:user, email: 'invalid_email@') }
      it 'Returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'Returns the JSON data for the errors' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
      end
    end

  end
end
