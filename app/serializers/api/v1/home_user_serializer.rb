class Api::V1::HomeUserSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :name

  def name
  	object.try(:name) || "Sin nombre"
  end

end
