require "rails_helper"

RSpec.describe "I18n" do
  def flatten_keys(hash, prefix = nil)
    hash.flat_map do |key, value|
      path = [ prefix, key ].compact.join(".")
      value.is_a?(Hash) ? flatten_keys(value, path) : [ path ]
    end
  end

  it "has the same keys in English and Brazilian Portuguese" do
    en = flatten_keys(YAML.load_file(Rails.root.join("config/locales/en.yml"))["en"])
    pt = flatten_keys(YAML.load_file(Rails.root.join("config/locales/pt-BR.yml"))["pt-BR"])

    expect(pt).to match_array(en)
  end
end
