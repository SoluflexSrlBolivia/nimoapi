class Api::V1::UserSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :name, :firstname, :lastname, :gender, :birthday, :notification,
  					 :country, :subregion, :occupation, :phone_number, :aliases

  has_one :folder

  def aliases
    ActiveModel::ArraySerializer.new(
      object.aliases,
      each_serializer: Api::V1::AliasSerializer
    )
  end

  def name
  	object.try(:name) || "Sin nombre"
  end

end
