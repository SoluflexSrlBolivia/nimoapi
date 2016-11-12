class Api::V1::HomePostSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :post, :description, :archive, :group, :rate, :user, :comments, :votes, :created_at, :updated_at
  
  
  def archive
  	Api::V1::HomeArchiveSerializer.new(object.archive, root: false) unless object.archive.nil?
  end
  
  def rate
    object.rate
  end
  def votes
    object.rates.count
  end

  def group
    Api::V1::HomeGroupSerializer.new(object.group, root: false)
  end

  def user
  	Api::V1::HomeUserSerializer.new(object.user, root: false)
  end

  def comments
    object.comments.count
  end
end
