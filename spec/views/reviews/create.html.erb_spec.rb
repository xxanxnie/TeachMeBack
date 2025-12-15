require 'rails_helper'

RSpec.describe "reviews/create.html.erb", type: :view do
  it "renders a simple placeholder" do
    render
    expect(rendered).to include("Reviews#create")
  end
end
