require 'httparty'
require 'nokogiri'

class Scraper
  BASE_URL = 'https://www.ycombinator.com/companies'

  def initialize(n, filters)
    @n = n
    @filters = filters
    @companies = []
  end

  def scrape
    current_page = 1
    while @companies.size < @n
      url = "#{BASE_URL}?page=#{current_page}&#{filter_params}"
      page = HTTParty.get(url)
      parse_page(page)
      current_page += 1
    end
    @companies.first(@n)
  end

  private

  def filter_params
    @filters.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  def parse_page(page)
    parsed_page = Nokogiri::HTML(page)
    companies = parsed_page.css('.company')
    companies.each do |company|
      break if @companies.size >= @n

      company_data = {
        name: company.css('.company-name').text,
        location: company.css('.company-location').text,
        description: company.css('.company-description').text,
        batch: company.css('.company-batch').text
      }
      
      company_url = company.css('.company-link').attr('href').value
      detailed_page = HTTParty.get(company_url)
      parse_detailed_page(detailed_page, company_data)
      
      @companies << company_data
    end
  end

  def parse_detailed_page(page, company_data)
    parsed_page = Nokogiri::HTML(page)
    company_data[:website] = parsed_page.css('.company-website').text
    founders = parsed_page.css('.founders .founder')
    company_data[:founders] = founders.map do |founder|
      {
        name: founder.css('.founder-name').text,
        linkedin: founder.css('.founder-linkedin a').attr('href').value
      }
    end
  end
end
