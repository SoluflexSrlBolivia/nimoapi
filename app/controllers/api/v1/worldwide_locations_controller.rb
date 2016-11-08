class Api::V1::WorldwideLocationsController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "lista de paises"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  example "Response" + '
{
  "countries": [
    {
      "name": "Andorra",
      "code": "AD"
    },
    {
      "name": "United Arab Emirates",
      "code": "AE"
    },
    {
      "name": "Afghanistan",
      "code": "AF"
    },
    {
      "name": "Antigua and Barbuda",
      "code": "AG"
    },
    {
      "name": "Anguilla",
      "code": "AI"
    },
    {
      "name": "Albania",
      "code": "AL"
    },
    {
      "name": "Armenia",
      "code": "AM"
    },
    {
      "name": "Angola",
      "code": "AO"
    },
    {
      "name": "Antarctica",
      "code": "AQ"
    },
    {
      "name": "Argentina",
      "code": "AR"
    },

    .....
  ]
}'
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

  api! "Subregiones de un Pais"
	meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
			 :url => "/api/v1/worldwide_locations/bo",
       :id => "bo"
	param :id, String, :desc => "Code of Country", :required => true
	error 401, "Bad credentials"
	error 403, "not authorized"
	example "Response" + '
{
  "subregions": [
    {
      "name": "El Beni",
      "code": "B",
      "type": "department"
    },
    {
      "name": "Cochabamba",
      "code": "C",
      "type": "department"
    },
    {
      "name": "Chuquisaca",
      "code": "H",
      "type": "department"
    },
    {
      "name": "La Paz",
      "code": "L",
      "type": "department"
    },
    {
      "name": "Pando",
      "code": "N",
      "type": "department"
    },
    {
      "name": "Oruro",
      "code": "O",
      "type": "department"
    },
    {
      "name": "Potosí",
      "code": "P",
      "type": "department"
    },
    {
      "name": "Santa Cruz",
      "code": "S",
      "type": "department"
    },
    {
      "name": "Tarija",
      "code": "T",
      "type": "department"
    }
  ]
}'
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