class Api::V1::RatePostsController < Api::V1::BaseController
  before_filter :authenticate_user!

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
      json: Api::V1::HomePostSerializer.new(rate.post).to_json,
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