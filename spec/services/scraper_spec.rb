require 'rails_helper'


RSpec.describe Scraper, type: :service do
  let(:filters) { { batch: 'W21', industry: 'Healthcare', region: 'United States' } }
  let(:scraper) { described_class.new(n, filters) }

  before do
    stub_request(:get, /https:\/\/www.ycombinator.com\/companies/).to_return(body: File.read('spec/fixtures/yc_companies.html'))
    stub_request(:get, /https:\/\/www.ycombinator.com\/companies\/.*/).to_return(body: File.read('spec/fixtures/yc_company_details.html'))
  end

  describe '#scrape' do
    context 'when n is 10' do
      let(:n) { 10 }

      it 'returns the correct number of companies' do
        companies = scraper.scrape
        expect(companies.size).to eq(n)
      end
    end

    context 'when n is 5' do
      let(:n) { 5 }

      it 'returns the correct number of companies' do
        companies = scraper.scrape
        expect(companies.size).to eq(n)
      end
    end

    context 'when the filters are applied' do
      let(:n) { 10 }

      it 'scrapes company data correctly' do
        companies = scraper.scrape
        company = companies.first

        expect(company[:name]).to eq('Reshape Biotech')
        expect(company[:location]).to eq('Copenhagen, Denmark')
        expect(company[:description]).to eq('Robots that automate the everyday tasks of microbiologists.')
        expect(company[:batch]).to eq('W21')
        expect(company[:website]).to eq('https://www.samplecompany.com')
        expect(company[:founders].first[:name]).to eq('Jane Doe')
        expect(company[:founders].first[:linkedin]).to eq('https://www.linkedin.com/in/janedoe')
      end
    end
  end
end