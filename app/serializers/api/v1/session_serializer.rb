class Api::V1::SessionSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :email, :token, :name

  def token
    object.authentication_token
  end

  def name
  	object.try(:name) || "Sin nombre"
  end

end
