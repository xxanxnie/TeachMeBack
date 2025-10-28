require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with name, .edu email, and password" do
    u = User.new(name: "Kiel", email: "k@school.edu", password: "secret")
    expect(u).to be_valid
    expect(u.edu_verified).to eq(true)
  end

  it "rejects non-.edu email and sets edu_verified false" do
    u = User.new(name: "Kiel", email: "k@gmail.com", password: "secret")
    expect(u).not_to be_valid
    expect(u.errors[:email]).to include(".edu email required")
    expect(u.edu_verified).to eq(false)
  end

  it "requires a name" do
    u = User.new(email: "k@school.edu", password: "secret")
    expect(u).not_to be_valid
    expect(u.errors[:name]).to be_present
  end
end


