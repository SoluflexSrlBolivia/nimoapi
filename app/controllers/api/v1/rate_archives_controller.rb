class Api::V1::RateArchivesController < Api::V1::BaseController
  before_filter :authenticate_user!

	def_param_group :create do
		param :rate, Hash, :required => true do
			param :archive_id, Fixnum, :desc => "ID Archive ", :required => true
			param :rate, [1,2,3,4,5], :desc => "Valoracion del archivo entre 1 - 5",  :required => true
			param :user_id, Fixnum, :desc => "ID del usuario", :required => true
		end
  end

	api! "Calificar un archivo"
	param_group :create
	error 401, "Bad credentials"
	error 403, "not authorized"
	error 422, "API Error"
	example "Response" + '

'
  def create
  	rate = RateArchive.find_by(:archive_id=>create_params[:archive_id], :user_id=>create_params[:user_id])
  	if rate.nil?
  		rate = RateArchive.new(create_params)
  		return api_error(status: 422, errors: rate.errors) unless rate.valid?

	    rate.save!
	  else
	    rate.rate = create_params[:rate]
	    rate.save!
  	end

  	render(
      json: Api::V1::HomeArchiveSerializer.new(rate.archive).to_json,
      status: 201,
      location: api_v1_archive_path(rate.archive.id)
    )
  end

  private
  	def create_params
  		params.require(:rate).permit(
        :archive_id, :rate, :user_id
      ).delete_if{ |k,v| v.nil?}
  	end

end