class Api::V1::UserArchiveSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :name, :lastname, :notification, :phone_number

  def name
  	object.try(:name) || "Sin nombre"
  end

end
