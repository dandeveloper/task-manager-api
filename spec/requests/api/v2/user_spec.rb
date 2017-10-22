require 'rails_helper'

RSpec.describe 'Users AIP', type: :request do
  let!(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:headers) do
    {
      'Accept' => 'application/vnd.taskmanagerapi.v2',
      'Content-Type' => Mime[:json].to_s,
      'Authorization' => user.auth_token
    }
  end

  before { host! 'api.taskmanagerapi.dev' }

  describe "GET /users/:id" do
    before do
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context 'When user exists' do
      it 'Returns the user' do
        expect(json_body[:id]).to eq(user_id)
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
      post '/users', params: { user: user_params }.to_json, headers: headers
    end

    context 'When the request params are valid' do
      let(:user_params) { attributes_for(:user) }

      it 'Returns the status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'Returns the JSON data for created user' do
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context 'When the request params are invalid' do
      let(:user_params) { attributes_for(:user, email: 'invalid_email@') }
      it 'Returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'Returns the JSON data for the errors' do
        expect(json_body).to have_key(:errors)
      end
    end

  end

  describe 'PUT /users/:id' do
    before do
      put "/users/#{user_id}", params: { user: user_params }.to_json, headers: headers
    end

    context 'when the request params are valid' do
      let(:user_params) { { email: "danilotremere@taskamanager.com" } }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the json data for the updated user' do
        json_body = JSON.parse(response.body, symbolize_names: true)
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context 'When the request params are invalid' do
      let(:user_params) { { email: "danilotremere@" } }

      it 'Returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'Returns the JSON data for the errors' do
        expect(json_body).to have_key(:errors)
      end
    end

  end

  describe 'DELETE /users/:id' do
    before do
      delete "/users/#{user_id}", params: {}, headers: headers
    end

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end

    it 'removes the user from database' do
      expect(User.find_by(id: user_id)).to be_nil
    end
  end
end
