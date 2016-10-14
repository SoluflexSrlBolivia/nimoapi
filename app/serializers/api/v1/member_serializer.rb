class Api::V1::MemberSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :name, :lastname, :notification, :phone_number, :gender, :occupation, :country

  def name
  	object.try(:name) || "Sin nombre"
  end

  def country
    Carmen::Country.coded(object.country).name unless object.country.nil?
  end
end
