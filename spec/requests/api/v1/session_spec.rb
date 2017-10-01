require 'rails_helper'

RSpec.describe 'Session API', type: :request do
  before { host! 'api.taskmanager.dev' }
  let(:user) { create(:user) }

  let(:headers) do
    {
      'Accept' => 'application/vnd.taskmanagerapi.v1',
      'Content-Type' => Mime[:json].to_s
    }
  end

  describe 'POST /sessions' do
    before(:each) do
      post '/sessions', params: { session: credentials }.to_json, headers: headers
    end

    context 'When credentials are correct' do
      let(:credentials) { { email: user.email, password: '123456' } }

      it "returns http status 200" do
        expect(response).to have_http_status(200)
      end

      it "returns the json data for the user with auth token" do
        user.reload
        expect(json_body[:auth_token]).to eq(user.auth_token)
      end
    end

    context 'When credentials are incorrect' do
      let(:credentials) { { email: user.email, password: 'invalid_password' } }

      it "returns http status 401" do
        expect(response).to have_http_status(401)
      end

      it "returns the json data for the erros" do
        expect(json_body).to have_key(:errors)
      end
    end
  end

  describe 'DELETE /sessions/:id' do
    let(:auth_token) { user.auth_token }

    before(:each) do
      delete "/sessions/#{auth_token}", params: {}, headers: headers
    end

    it "returns http status 204" do
      expect(response).to have_http_status(204)
    end

    it 'changes the user auth token' do
      expect( User.find_by(auth_token: auth_token) ).to be_nil
    end
  end
end