class Api::V1::UserSearchSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :fullname, :name, :lastname, :phone_number, :gender

  def fullname
  	object.try(:fullname) || "Sin nombre"
  end

end
