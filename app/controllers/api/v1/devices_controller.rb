class Api::V1::DevicesController < Api::V1::BaseController
  before_filter :authenticate_user!

  def create
  	device = Device.new(create_params.merge(:user_id=>current_user.id))
    
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
	      :identifier, :version, :os, :model, :idDevice
	    ).delete_if{ |k,v| v.nil?}
  	end
end