require "rails_helper"

RSpec.describe Api::UsersController, type: :request do
  context "when trying to sign up with valid parameters" do
    before(:all) do
      @user = build(:user)
      post "/users", {
        name: @user.name,
        email: @user.email,
        password: @user.password,
        password_confirmation: @user.password
      }.to_json, "Content-Type" => "application/json",
                 "HTTP_ACCEPT" => "application/vnd.bucketlist.v1"
    end
    it "returns a status code of 201" do
      expect(response).to have_http_status 201
    end

    it "returns the newly created user" do
      expect(json["user"]["name"]).to eq @user.name
    end
  end

  context "when trying to sign up with invalid parameters" do
    before(:all) do
      invalid_user = build(:invalid_user)
      post "/users", {
        name: invalid_user.name,
        email: invalid_user.email,
        password: invalid_user.password,
        password_confirmation: invalid_user.password_confirmation
      }.to_json, "Content-Type" => "application/json", "HTTP_ACCEPT" =>
      "application/vnd.bucketlist.v1"
    end

    it "returns a status code of 422" do
      expect(response).to have_http_status(422)
    end
    it "returns descriptive error message" do
      expect(json["errors"]["password"].first).to include("is too short")
    end
  end
end
