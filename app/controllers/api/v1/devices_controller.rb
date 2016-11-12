class Api::V1::DevicesController < Api::V1::BaseController
  before_filter :authenticate_user!


  def_param_group :create do
    param :device, Hash, :required => true do
      param :user_id, Fixnum, :required => true
      param :identifier, String, :required => true
      param :version, String
      param :os, String
      param :model, String
      param :player_id, String, :required => true
      param :name_device, String
    end
  end

  api! "Registro de un dispositivo mobil iOS/Android"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  param_group :create
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "No se puede registrar el dispositivo"
  example "Post:" + '
  device[user_id]:1
  device[identifier]:5675gjgjkhj
  device[player_id]:23423423423
  '+
"
Response" + '
  {"status":"ok"}'
  def create
    device = Device.find_by_player_id create_params[:player_id]
    if device.nil?
      device = Device.new(create_params)
      return api_error(status: 422, errors: device.errors) unless device.valid?

      device.save!
    else
      if !device.update_attributes(create_params)
        return api_error(status: 422, errors: device.errors)
      end
    end



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