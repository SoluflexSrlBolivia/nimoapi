class Api::V1::HomeUserSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :fullname

  def fullname
  	object.try(:fullname) || "Sin nombre"
  end

end
