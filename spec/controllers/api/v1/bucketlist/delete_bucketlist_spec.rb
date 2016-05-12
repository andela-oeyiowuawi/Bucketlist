require "rails_helper"

RSpec.describe "when trying to delete a bucketlist", type: :request do
  before(:all) do
    @user1 = create(:user, active_status: true)
    @user2 = create(:user)
    @bucketlist1 = create(:bucket_list, created_by: @user1.id)
    @bucketlist2 = create(:bucket_list, created_by: @user2.id)
    token = token_generator(@user1)
    @headers = {
      "HTTP_AUTHORIZATION" => token,
      "Content-Type" => "application/json",
      "HTTP_ACCEPT" => "application/vnd.bucketlist.v1"
    }
  end

  describe "as a logged In user" do
    context "that owns the  bucketlist" do
      it "returns a status code of 204" do
        delete "/bucketlists/#{@bucketlist1.id}", {}, @headers
        expect(response).to have_http_status 204
      end
    end

    context "that doesn't own the bucketlist " do
      it "returns a status code of 404" do
        delete "/bucketlists/#{@bucketlist2.id}", {}, @headers
        expect(response).to have_http_status 404
      end
    end

    context "deletes items when delete bucketlist" do
      it "should reduce item count by 3" do
        bucketlist = create(:bucket_list, created_by: @user1.id)
        create_list(:item, 3, bucket_list: bucketlist)
        expect do
          delete "/bucketlists/#{bucketlist.id}", {}, @headers
        end.to change(Item, :count).by(-3)
      end
    end
  end
end
