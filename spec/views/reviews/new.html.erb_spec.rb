require 'rails_helper'

RSpec.describe "reviews/new.html.erb", type: :view do
  let(:user) { User.create!(email: "me@school.edu", password: "secretpass", name: "Me User") }
  let(:partner) { User.create!(email: "you@school.edu", password: "secretpass", name: "You User") }
  let(:request_record) do
    SkillExchangeRequest.create!(
      user: partner,
      teach_skill: "Guitar",
      teach_level: "beginner",
      teach_category: "music_art",
      learn_skill: "Python",
      learn_level: "beginner",
      learn_category: "tech_academics",
      offer_hours: 2,
      modality: "remote",
      expires_after_days: 30,
      availability_days: [1]
    )
  end

  it "renders the review form with partner options" do
    assign(:request, request_record)
    assign(:partners, [partner])
    assign(:review, Review.new)

    render

    expect(rendered).to include("Leave a Review")
    expect(rendered).to have_selector("select[name='reviewee_id']")
    expect(rendered).to include(partner.full_name)
    expect(rendered).to include("Your Feedback")
  end
end
