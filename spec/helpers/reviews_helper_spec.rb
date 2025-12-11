require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ReviewsHelper. For example:
#
# describe ReviewsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ReviewsHelper, type: :helper do
  describe "#star_string" do
    it "renders filled and empty stars for a given rating" do
      expect(helper.star_string(3)).to eq("★★★☆☆")
      expect(helper.star_string(5)).to eq("★★★★★")
    end

    it "handles nil rating as no stars" do
      expect(helper.star_string(nil)).to eq("☆☆☆☆☆")
    end
  end
end
