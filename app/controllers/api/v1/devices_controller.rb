class Api::V1::DevicesController < Api::V1::BaseController
  before_filter :authenticate_user!

  def create
  	device = Device.new(create_params)
    
  	return api_error(status: 422, errors: device.errors) unless device.valid?

    device.save!

    render(
      json: {:status=>"ok"},
      status: 201
    )
  end

  private 
  	def create_params
  		params.require(:device).permit(
	      :user_id, :identifier, :version, :os, :model, :player_id, :name_device
	    ).delete_if{ |k,v| v.nil?}
  	end
end