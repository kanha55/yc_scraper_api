require 'rails_helper'

RSpec.describe Api::V1::CompaniesController, type: :controller do
  describe 'GET #index' do
    let(:valid_params) do
      {
        n: 10,
        filters: {
          batch: 'W21',
          industry: 'Healthcare',
          region: 'United States'
        }
      }
    end

    before do
      stub_request(:get, /ycombinator.com/).to_return(body: File.read('spec/fixtures/yc_companies.html'))
      stub_request(:get, /ycombinator.com\/companies\/.*/).to_return(body: File.read('spec/fixtures/yc_company_details.html'))
    end

    it 'returns a CSV response' do
      get :index, params: valid_params, format: :csv

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('text/csv')
    end

    it 'returns the correct CSV data' do
      get :index, params: valid_params, format: :csv

      csv_data = CSV.parse(response.body, headers: true)
      expect(csv_data.count).to eq(10)

      first_company = csv_data.first
      expect(first_company['Name']).to eq('Reshape Biotech')
      expect(first_company['Location']).to eq('Copenhagen, Denmark')
      expect(first_company['Description']).to eq('A healthcare startup.')
      expect(first_company['Batch']).to eq('W21')
      expect(first_company['Website']).to eq('https://www.samplecompany.com')
      expect(first_company['Founders']).to include('Jane Doe (https://www.linkedin.com/in/janedoe)')
    end
  end
end
