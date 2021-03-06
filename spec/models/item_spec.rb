require "rails_helper"

RSpec.describe Item, type: :model do
  subject { build(:item) }
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to belong_to(:bucket_list) }
  end
end
