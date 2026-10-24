require "rails_helper"

RSpec.describe Github::Authentication::Providers::KeycloakBroker do
  let(:body) { "" }
  let(:response) { instance_double(Net::HTTPOK, body: body, is_a?: true) }

  before { allow(Net::HTTP).to receive(:start).and_return(response) }

  context "with a form-encoded payload" do
    let(:body) { "access_token=gho_abc&scope=read%3Auser&token_type=bearer" }

    it "extracts the GitHub token" do
      expect(described_class.call(access_token: "kc").result).to eq("gho_abc")
    end
  end

  context "with a JSON payload" do
    let(:body) { { access_token: "gho_json" }.to_json }

    it "extracts the GitHub token" do
      expect(described_class.call(access_token: "kc").result).to eq("gho_json")
    end
  end

  context "without a token in the payload" do
    let(:body) { "scope=read" }

    it "reports an error" do
      expect(described_class.call(access_token: "kc").errors).to include("GitHub token not available in Keycloak")
    end
  end

  it "requires the Keycloak token" do
    expect(described_class.call.errors).to include("Keycloak access token is required")
  end
end
