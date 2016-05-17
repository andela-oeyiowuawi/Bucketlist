require "rails_helper"

RSpec.describe "list all the bucketlists", type: :request do
  before(:all) do
    @user = create(:user, active_status: true)
    token = token_generator(@user)
    @headers = {
      "HTTP_AUTHORIZATION" => token,
      "Content-Type" => "application/json",
      "HTTP_ACCEPT" => "application/vnd.bucketlist.v1"
    }
  end

  context "when the user has no bucketlist" do
    before(:all) do
      get "/bucketlists", {}, @headers
    end
    it "returns a status code of 200" do
      expect(response).to have_http_status 200
    end
    it "returns a message for the user " do
      expect(json["message"]).to eq "You have no bucketlist"
    end
  end

  context "when the user has bucketlist" do
    before(:each) do
      create_list(:bucket_list, 3, created_by: @user.id)
      create(:bucket_list)
      get "/bucketlists", {}, @headers
    end

    it "should return a 200 status code" do
      expect(response).to have_http_status 200
    end

    it "return bucketlist belonging to current user" do
      user_id = []
      json.each { |hsh| user_id << hsh["created_by"] }
      contain_user_id = user_id.all? { |id| id == @user.id }
      expect(contain_user_id).to eq true
    end
    it "should return a count of 3" do
      expect(json.count).to eq 3
    end
  end

  context "when user has an incomplete request" do
    before(:each) do
      headers = {
        "HTTP_AUTHORIZATION" => nil,
        "Content-Type" => "application/json",
        "HTTP_ACCEPT" => "application/vnd.bucketlist.v1"
      }

      post "/bucketlists", { name: nil }.to_json, headers
    end
    it "should return errors for non-logged-in user" do
      expect(json["errors"]).to include "Not Authenticated"
    end
    it "should return a unauthorized status code" do
      expect(response).to have_http_status 401
    end
  end

  describe "Pagination" do
    before(:all) do
      @bucketlist = create_list(:bucket_list, 30, created_by: @user.id)
    end

    context "when requesting with only page parameter" do
      before(:all) do
        get "/bucketlists?page=2", {}, @headers
      end

      it "should return just 10 bucketlists" do
        expect(json.count).to eq 10
      end
      it "should return a status code of 200" do
        expect(response).to have_http_status 200
      end
      it "should return the correct bucketlist" do
        names = json.map { |hsh| hsh["name"] }
        a = 0
        b = 20
        10.times do
          expect(names[a]).to eq @bucketlist[b]["name"]
          a += 1
          b += 1
        end
      end
    end

    context "when requesting with only limit" do
      before(:all) do
        get "/bucketlists?limit=5", {}, @headers
      end

      it "returns a status code of 200" do
        expect(response).to have_http_status 200
      end

      it "returns the number of results based on the provided limit" do
        expect(json.count).to eq 5
      end
    end

    context "when requesting with limit and page number" do
      before(:all) do
        get "/bucketlists?page=2&limit=5", {}, @headers
      end

      it "returns a status code of 200" do
        expect(response).to have_http_status 200
      end
      it "returns the right number of bucketlist" do
        expect(json.count).to eq 5
      end
      it "returns the right bucketlists" do
        names = json.map { |hsh| hsh["name"] }
        a = 0
        b = 5
        5.times do
          expect(names[a]).to eq @bucketlist[b]["name"]
          a += 1
          b += 1
        end
      end
    end
  end

  describe "Search" do
    before(:all) do
      create(:bucket_list, name: "Late Thirties", user: @user)
      create(:bucket_list, name: "Early Thirties", user: @user)
      create(:bucket_list, name: "Mid Twenties", user: @user)
    end

    context "when searching with valid search query" do
      before(:all) do
        get "/bucketlists?q=Thirties", {}, @headers
      end
      it "returns status code of 200" do
        expect(response).to have_http_status 200
      end
      it "returns the correct number of bucketlists" do
        expect(json.count).to eq 2
      end
      it "return bucketlist belonging to current user" do
        bucket_list_name = json.map { |hsh| hsh["name"] }
        result = bucket_list_name.all? { |name| name.include? "Thirties" }
        expect(result).to eq true
      end
    end

    context "when searching with invalid search query" do
      before(:all) do
        get "/bucketlists?q=party", {}, @headers
      end
      it "returns status code of 404" do
        expect(response).to have_http_status 404
      end
      it "returns the correct number of bucketlists" do
        expect(json["errors"]).to include "No result found"
      end
    end
  end
end
