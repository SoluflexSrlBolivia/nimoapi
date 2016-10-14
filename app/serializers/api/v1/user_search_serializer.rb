class Api::V1::UserSearchSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :name, :firstname, :lastname, :phone_number

  def name
  	object.try(:name) || "Sin nombre"
  end

end
