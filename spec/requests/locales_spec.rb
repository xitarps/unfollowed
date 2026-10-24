require "rails_helper"

RSpec.describe "Locales", type: :request do
  it "defaults to English" do
    get root_path

    expect(response.body).to include("Welcome!", '<html lang="en">')
  end

  it "switches to Brazilian Portuguese and keeps the choice in the session" do
    patch locale_path(locale: "pt-BR")
    follow_redirect!

    expect(response.body).to include("Bem-vindo!", '<html lang="pt-BR">')

    get root_path
    expect(response.body).to include("Bem-vindo!")
  end

  it "switches back to English" do
    patch locale_path(locale: "pt-BR")
    patch locale_path(locale: "en")
    follow_redirect!

    expect(response.body).to include("Welcome!")
  end

  it "ignores unsupported locales" do
    patch locale_path(locale: "xx")
    follow_redirect!

    expect(response.body).to include("Welcome!")
  end

  it "renders the toggle in the navbar" do
    get root_path

    expect(response.body).to include("locale-toggle", ">EN<", ">PT<", 'data-controller="loading-button"')
  end
end
