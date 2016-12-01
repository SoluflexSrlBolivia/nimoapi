class Api::V1::MemberSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :fullname, :notification, :phone_number, :gender, :occupation, :country, :alias

  def fullname
  	object.try(:fullname) || "Sin nombre"
  end

  def country
    Carmen::Country.coded(object.country).name unless object.country.nil?
  end
  def alias
    group = scope[:group]
    if group.present?
      user_group = UserGroup.find_by(:user_id=>object.id, :group_id=>group.id)
      return nil if user_group.nil?

      return nil if user_group.alias.nil?

      aalias = Alias.find_by_name user_group.alias

      return Api::V1::AliasSerializer.new(aalias, root: false) unless aalias.nil?

      return {:name=>user_group.alias}
    end
  end
end
