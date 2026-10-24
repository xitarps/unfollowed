require "rails_helper"

RSpec.describe "Pages", type: :request do
  {
    "/terms" => [ "Terms of Use", "Termos de Uso" ],
    "/privacy" => [ "Privacy Policy", "Política de Privacidade" ],
    "/contact" => [ "Contact", "Contato" ]
  }.each do |path, (english, portuguese)|
    it "renders #{path} in English by default" do
      get path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(english)
    end

    it "renders #{path} in Brazilian Portuguese" do
      patch "/locale", params: { locale: "pt-BR" }
      get path

      expect(response.body).to include(portuguese)
    end
  end

  it "links the footer to the pages" do
    get root_path

    expect(response.body).to include('href="/terms"', 'href="/privacy"', 'href="/contact"')
  end

  it "shows the contact email" do
    get contact_path

    expect(response.body).to include("mailto:xitamailer@gmail.com")
  end
end
