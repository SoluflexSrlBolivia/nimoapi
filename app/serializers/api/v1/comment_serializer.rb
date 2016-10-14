class Api::V1::CommentSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :comment, :user, :alias,  :created_at, :updated_at
  
  def user
  	Api::V1::HomeUserSerializer.new(object.user, root: false)
  end

end
