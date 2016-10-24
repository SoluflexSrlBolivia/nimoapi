class Api::V1::UserArchiveSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :fullname, :name, :notification, :phone_number

  def fullname
  	object.try(:fullname) || "Sin nombre"
  end

end
