require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do
  describe 'when trying to sign up' do
    it 'creates a user with the correct attributes' do
      user = build(:user)
      post '/users', {
        name: user.name,
        email: user.email,
        password: user.password,
        password_confirmation: user.password
      }.to_json, 'Content-Type' => 'application/json',
      'HTTP_ACCEPT' => 'application/vnd.bucketlist.v1'
      expect(response).to have_http_status 201
    end
    it 'returns error for invalid user attributes' do
      user = build(:invalid_user)
      post '/users', {
        name: user.name,
        email: user.email,
        password: user.password,
        password_confirmation: user.password_confirmation
      }.to_json, 'Content-Type' => 'application/json', 'HTTP_ACCEPT' =>
      'application/vnd.bucketlist.v1'
      expect(response).to have_http_status(422)
      expect(json['errors']['password'].first).to include('is too short')
    end
  end
end
