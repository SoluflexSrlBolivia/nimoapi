class Api::V1::MemberSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :fullname, :notification, :phone_number, :gender, :occupation, :country

  def fullname
  	object.try(:fullname) || "Sin nombre"
  end

  def country
    Carmen::Country.coded(object.country).name unless object.country.nil?
  end
end
