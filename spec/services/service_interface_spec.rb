require "rails_helper"

RSpec.describe ServiceInterface do
  it "raises when run is not implemented" do
    expect { described_class.call }.to raise_error(NotImplementedError)
  end
end
