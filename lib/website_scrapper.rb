class HtmlParserIncluded < HTTParty::Parser
  def html
    Nokogiri::HTML(body)
  end
end

class WebsiteScrapper
  include HTTParty
  parser HtmlParserIncluded

  def self.titles(url)
    nokogiri = WebsiteScrapper.get(url)

    {
      titles: nokogiri.search('h1').map { |item| item.text.squish },
      subtitles: nokogiri.search('h2, h3').map { |item| item.text.squish },
    }
  end
end
