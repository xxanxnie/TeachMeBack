require "rails_helper"

RSpec.describe SkillExchangeRequest, type: :model do
  let(:user) { User.create!(name: "Test User", email: "test@school.edu", password: "password123") }
  
  let(:valid_attributes) do
    {
      user: user,
      teach_skill: "Guitar",
      teach_level: "intermediate",
      teach_category: "music_art",
      learn_skill: "Python",
      learn_level: "beginner",
      learn_category: "tech_academics",
      offer_hours: 5,
      modality: "in_person",
      expires_after_days: 30,
      availability_days: [1, 3, 5]
    }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      request = SkillExchangeRequest.new(valid_attributes)
      expect(request).to be_valid
    end

    it "requires teach_skill" do
      request = SkillExchangeRequest.new(valid_attributes.except(:teach_skill))
      expect(request).not_to be_valid
      expect(request.errors[:teach_skill]).to include("can't be blank")
    end

    it "requires learn_skill" do
      request = SkillExchangeRequest.new(valid_attributes.except(:learn_skill))
      expect(request).not_to be_valid
      expect(request.errors[:learn_skill]).to include("can't be blank")
    end

    it "requires teach_level" do
      request = SkillExchangeRequest.new(valid_attributes.merge(teach_level: nil))
      expect(request).not_to be_valid
      expect(request.errors[:teach_level]).to include("can't be blank")
    end

    it "requires learn_level" do
      request = SkillExchangeRequest.new(valid_attributes.merge(learn_level: nil))
      expect(request).not_to be_valid
      expect(request.errors[:learn_level]).to include("can't be blank")
    end

    it "requires offer_hours" do
      request = SkillExchangeRequest.new(valid_attributes.merge(offer_hours: nil))
      expect(request).not_to be_valid
      expect(request.errors[:offer_hours]).to include("can't be blank")
    end

    it "requires modality" do
      request = SkillExchangeRequest.new(valid_attributes.merge(modality: nil))
      expect(request).not_to be_valid
      expect(request.errors[:modality]).to include("can't be blank")
    end

    it "requires expires_after_days" do
      request = SkillExchangeRequest.new(valid_attributes.except(:expires_after_days))
      expect(request).not_to be_valid
      expect(request.errors[:expires_after_days]).to include("can't be blank")
    end

    it "requires at least one availability day" do
      request = SkillExchangeRequest.new(valid_attributes.merge(availability_days: []))
      expect(request).not_to be_valid
      expect(request.errors[:availability_days]).to include("must include at least one day")
    end

    it "validates offer_hours is an integer" do
      request = SkillExchangeRequest.new(valid_attributes.merge(offer_hours: 5.5))
      expect(request).not_to be_valid
    end

    it "validates offer_hours is greater than 0" do
      request = SkillExchangeRequest.new(valid_attributes.merge(offer_hours: 0))
      expect(request).not_to be_valid
      expect(request.errors[:offer_hours]).to include("must be greater than 0")
    end

    it "validates offer_hours is less than or equal to 40" do
      request = SkillExchangeRequest.new(valid_attributes.merge(offer_hours: 41))
      expect(request).not_to be_valid
      expect(request.errors[:offer_hours]).to include("must be less than or equal to 40")
    end

    it "validates expires_after_days is greater than or equal to 7" do
      request = SkillExchangeRequest.new(valid_attributes.merge(expires_after_days: 6))
      expect(request).not_to be_valid
      expect(request.errors[:expires_after_days]).to include("must be greater than or equal to 7")
    end

    it "validates expires_after_days is less than or equal to 180" do
      request = SkillExchangeRequest.new(valid_attributes.merge(expires_after_days: 181))
      expect(request).not_to be_valid
      expect(request.errors[:expires_after_days]).to include("must be less than or equal to 180")
    end

    it "validates modality is in allowed values" do
      request = SkillExchangeRequest.new(valid_attributes.merge(modality: "invalid"))
      expect(request).not_to be_valid
      expect(request.errors[:modality]).to include("is not included in the list")
    end

    it "allows valid modalities" do
      %w[in_person remote hybrid].each do |modality|
        request = SkillExchangeRequest.new(valid_attributes.merge(modality: modality))
        expect(request).to be_valid
      end
    end

    it "validates learning_goal length is maximum 500 characters" do
      request = SkillExchangeRequest.new(valid_attributes.merge(learning_goal: "a" * 501))
      expect(request).not_to be_valid
      expect(request.errors[:learning_goal]).to include("is too long (maximum is 500 characters)")
    end

    it "allows blank learning_goal" do
      request = SkillExchangeRequest.new(valid_attributes.merge(learning_goal: ""))
      expect(request).to be_valid
    end
  end

  describe "normalization" do
    it "strips whitespace from teach_skill" do
      request = SkillExchangeRequest.create!(valid_attributes.merge(teach_skill: "  Guitar  "))
      expect(request.teach_skill).to eq("Guitar")
    end

    it "strips whitespace from learn_skill" do
      request = SkillExchangeRequest.create!(valid_attributes.merge(learn_skill: "  Python  "))
      expect(request.learn_skill).to eq("Python")
    end
  end

  describe "availability_days" do
    it "sets and gets availability days correctly" do
      request = SkillExchangeRequest.new(valid_attributes)
      request.availability_days = [0, 2, 4] # Sun, Tue, Thu
      expect(request.availability_days).to match_array([0, 2, 4])
    end

    it "handles availability days setter with array" do
      request = SkillExchangeRequest.new(valid_attributes)
      request.availability_days = ["1", "3", "5"]
      expect(request.availability_days).to match_array([1, 3, 5])
    end

    it "removes duplicates from availability days" do
      request = SkillExchangeRequest.new(valid_attributes)
      request.availability_days = [1, 1, 3, 3]
      expect(request.availability_days).to match_array([1, 3])
    end
  end

  describe "#expired?" do
    it "returns false for a new request" do
      request = SkillExchangeRequest.create!(valid_attributes.merge(expires_after_days: 30))
      expect(request.expired?).to be false
    end

    it "returns true for a request past expiration" do
      request = SkillExchangeRequest.create!(
        valid_attributes.merge(
          expires_after_days: 30,
          created_at: 31.days.ago
        )
      )
      expect(request.expired?).to be true
    end

    it "returns false when created_at is nil" do
      request = SkillExchangeRequest.new(valid_attributes)
      request.created_at = nil
      expect(request.expired?).to be false
    end
  end

  describe "scopes" do
    let!(:open_request) do
      SkillExchangeRequest.create!(valid_attributes.merge(status: :open))
    end
    let!(:matched_request) do
      SkillExchangeRequest.create!(valid_attributes.merge(status: :matched))
    end
    let!(:closed_request) do
      SkillExchangeRequest.create!(valid_attributes.merge(status: :closed))
    end

    it "finds recent requests first" do
      expect(SkillExchangeRequest.recent_first.first).to eq(closed_request)
    end

    it "finds only open requests" do
      expect(SkillExchangeRequest.status_open_only).to include(open_request)
      expect(SkillExchangeRequest.status_open_only).not_to include(matched_request)
      expect(SkillExchangeRequest.status_open_only).not_to include(closed_request)
    end
  end

  describe "enums" do
    it "has correct status enum values" do
      expect(SkillExchangeRequest.statuses.keys).to match_array(%w[open matched closed])
    end

    it "has correct teach_level enum values" do
      expect(SkillExchangeRequest.teach_levels.keys).to match_array(%w[beginner intermediate advanced])
    end

    it "has correct learn_level enum values" do
      expect(SkillExchangeRequest.learn_levels.keys).to match_array(%w[beginner intermediate advanced])
    end
  end

  describe "associations" do
    it "belongs to a user" do
      request = SkillExchangeRequest.create!(valid_attributes)
      expect(request.user).to eq(user)
      expect(request.user_id).to eq(user.id)
    end
  end

  describe "#expired?" do
    it "returns false for recent requests" do
      request = SkillExchangeRequest.create!(valid_attributes.merge(expires_after_days: 30))
      expect(request.expired?).to be false
    end

    it "returns true for expired requests" do
      request = SkillExchangeRequest.create!(
        valid_attributes.merge(
          expires_after_days: 7,
          created_at: 10.days.ago
        )
      )
      expect(request.expired?).to be true
    end

    it "returns false for non-expired requests that are old" do
      request = SkillExchangeRequest.create!(
        valid_attributes.merge(
          expires_after_days: 180,
          created_at: 30.days.ago
        )
      )
      expect(request.expired?).to be false
    end
  end

  describe "status transitions" do
    let(:request) { SkillExchangeRequest.create!(valid_attributes) }

    it "starts as open" do
      expect(request.status).to eq("open")
    end

    it "can transition to matched" do
      request.update!(status: :matched)
      expect(request.status).to eq("matched")
    end

    it "can transition to closed" do
      request.update!(status: :closed)
      expect(request.status).to eq("closed")
    end
  end
end
