require 'selenium-webdriver'
require 'nokogiri'

class Scraper
  BASE_URL = 'https://www.ycombinator.com'

  def initialize(n, filters)
    @n = n 
    @filters = filters
    @companies = []
    setup_driver
  end

  def scrape
    current_page = 1
    while @companies.size < @n 
      url = "#{BASE_URL}/companies?#{filter_params}"
      @driver.navigate.to(url)
      wait_for_companies_to_load
      parse_page(@driver.page_source)
      current_page += 1
    end
    @driver.quit
    @companies.first(@n)
  end

  private

  def setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    @driver = Selenium::WebDriver.for(:chrome, options: options)
  end

  def wait_for_companies_to_load
    wait = Selenium::WebDriver::Wait.new(timeout: 10) # seconds
    wait.until { @driver.find_elements(css: '._company_86jzd_338').any? }
  end

  def filter_params
    @filters.to_h.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  def parse_page(html)
    parsed_page = Nokogiri::HTML(html)
    companies = parsed_page.css('._company_86jzd_338')
   
    companies.each do |company|

      break if @companies.size >= @n

      company_data = {
        name: company.css('._coName_86jzd_453').text,
        location: company.css('._coLocation_86jzd_469').text,
        description: company.css('._coDescription_86jzd_478').text,
        batch: company.css('._pillWrapper_86jzd_33').text
      }
      
      company_url = company.attr('href')
      @driver.navigate.to("#{BASE_URL}"+ company_url)
      parse_detailed_page(@driver.page_source, company_data)
      
      @companies << company_data
    end
  end

  def parse_detailed_page(html, company_data)
    parsed_page = Nokogiri::HTML(html)
    company_data[:website] = parsed_page.css('.mb-2.whitespace-nowrap').text
    founders = parsed_page.css('.space-y-5 .flex-row.items-start')
    company_data[:founders] = founders.map do |founder|
      {
        name: founder.css('h3').text,
        linkedin: founder.css('.bg-image-linkedin').attr('href')&.value
      }
    end
  end
end
