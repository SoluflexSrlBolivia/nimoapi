class Api::V1::PostSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :post, :archive, :rate, :user, :comments, :votes, :alias, :created_at, :updated_at
  
  
  def archive
  	Api::V1::ArchiveSerializer.new(object.archive, root: false) unless object.archive.nil?
  end
  def rate
    object.rate
  end
  def votes
    object.rates.count
  end
  def user
  	Api::V1::HomeUserSerializer.new(object.user, root: false)
  end
  def comments
    object.comments.count
  end

  def alias
    return nil if object.alias.nil?

    aalias = Alias.find_by_name object.alias

    return Api::V1::AliasSerializer.new(aalias, root: false) unless aalias.nil?

    return {:name=>object.alias}
  end

end
