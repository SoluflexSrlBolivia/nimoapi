class Api::V1::CommentSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :comment, :user, :alias,  :created_at, :updated_at
  
  def user
  	Api::V1::HomeUserSerializer.new(object.user, root: false)
  end

  def alias
    current_user = scope[:current_user]
    if current_user.present?
      return nil if object.alias.nil?

      aalias = Alias.find_by_name object.alias

      return Api::V1::AliasSerializer.new(aalias, root: false) unless aalias.nil?

      return {:name=>object.alias}
    end

    object.alias
  end
end
