require "rails_helper"

RSpec.describe "when creating an item ", type: :request do
  before(:all) do

  end
  context "using a valid request" do
    before(:each) do
      @item = build(:item)
      token = token_generator(@item.bucket_list.user)
      headers = {
        "HTTP_AUTHORIZATION" => token,
        "Content-Type" => "application/json",
        "HTTP_ACCEPT" => "application/vnd.bucketlist.v1"
      }
      post "/bucketlists/#{@item.bucket_list.id}/items", {
        name: @item.name,
        done: @item.done
      }.to_json, headers
    end

    it "should return a status code of 201" do
      expect(response).to have_http_status 201
    end

    it "should return the name of the newly created item" do
      expect(json["item"]["name"]).to eq @item.name
    end
    it "should return the attribute done of the newly created item" do
      expect(json["item"]["done"]).to eq false
    end
  end

  context "using invalid request" do
    before(:each) do
      @item = build(:item)
      token = token_generator(@item.bucket_list.user)
      headers = {
        "HTTP_AUTHORIZATION" => token,
        "Content-Type" => "application/json",
        "HTTP_ACCEPT" => "application/vnd.bucketlist.v1"
      }
      post "/bucketlists/#{@item.bucket_list.id}/items", {
        name: nil,
        done: @item.done
      }.to_json, headers
    end
    it "should return  status a 422" do
      expect(response).to have_http_status 422
    end
    it "should return error message" do
      expect(json["errors"]["name"]).to eq ["can't be blank"]
    end
  end
end
