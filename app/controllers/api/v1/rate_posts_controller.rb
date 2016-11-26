class Api::V1::RatePostsController < Api::V1::BaseController
  before_filter :authenticate_user!

	def_param_group :create do
		param :rate, Hash, :required => true do
			param :post_id, Fixnum, :desc => "ID Post", :required => true
			param :rate, [1,2,3,4,5], :desc => "Valoracion del post entre 1 - 5",  :required => true
			param :user_id, Fixnum, :desc => "ID del usuario", :required => true
		end
  end

	api! "Calificar un post"
	param_group :create
	error 401, "Bad credentials"
	error 403, "not authorized"
	error 422, "API Error"
	example "Response" + '

'
  def create
  	rate = RatePost.find_by(:post_id=>create_params[:post_id], :user_id=>create_params[:user_id])
  	if rate.nil?
  		rate = RatePost.new(create_params)
  		return api_error(status: 422, errors: rate.errors) unless rate.valid?

	    rate.save!
	  else
	    rate.rate = create_params[:rate]
	    rate.save!
  	end

  	render(
      json: Api::V1::HomePostSerializer.new(rate.post, :root => "post").to_json,
      status: 201,
      location: api_v1_post_path(rate.post.id)
    )
  end

  private
  	def create_params
  		params.require(:rate).permit(
        :post_id, :rate, :user_id
      ).delete_if{ |k,v| v.nil?}
  	end
end