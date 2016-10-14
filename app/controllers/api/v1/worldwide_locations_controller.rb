class Api::V1::WorldwideLocationsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def index
  	countries = Carmen::Country.all.map do |c|
  		{
  			:name=>c.name,
  			:code=>c.code
  		}
  	end

  	render(
      json: {:countries=>countries}
    )
  end

  def show
  	country = Carmen::Country.coded params[:id]

  	subregions = country.subregions.map do |r|
  		{
  			:name=>r.name,
  			:code=>r.code,
  			:type=>r.type
  		}
  	end
  	render(
      json: {:subregions=>subregions}
    )
  end
end