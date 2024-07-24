class Api::V1::CompaniesController < ApplicationController
  def index
    scraper = Scraper.new(params[:n].to_i, filter_params)
    companies = scraper.scrape
    csv_data = companies_to_csv(companies)
    File.write('/home/kanha/Konnector/yc_scraper_api/companies.csv', csv_data)

    respond_to do |format|
      # format.html { render :index }
      format.csv { send_data companies_to_csv(companies), filename: "companies.csv" }
    end
  end

  private

  def filter_params
    params.permit(filters: [:batch, :industry, :region, :tag, :company_size, :is_hiring, :nonprofit, :black_founded, :hispanic_latino_founded, :women_founded])[:filters]
  end

  def companies_to_csv(companies)
    CSV.generate(headers: true) do |csv|
      csv << %w[Name Location Description Batch Website Founders]
      companies.each do |company|
        founders = company[:founders].map { |f| "#{f[:name]} (#{f[:linkedin]})" }.join('; ')
        csv << [company[:name], company[:location], company[:description], company[:batch], company[:website], founders]
      end
    end
  end
end
