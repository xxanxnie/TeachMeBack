require "rails_helper"

RSpec.describe ApplicationJob do
  it "inherits from ActiveJob::Base" do
    expect(described_class.superclass).to eq(ActiveJob::Base)
  end
end

RSpec.describe ApplicationMailer do
  it "sets a default from address" do
    expect(described_class.default[:from]).to eq("from@example.com")
  end
end
