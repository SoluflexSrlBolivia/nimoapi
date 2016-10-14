class Api::V1::HomeArchiveSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :size, :content_type, :rate, :group, :uploader, :comments, :votes, :created_at, :updated_at
  
  def name
  	object.digital_file_name
  end
  def size
  	object.digital_file_size
  end
  def content_type
  	object.digital_content_type
  end

  def rate
    object.rate
  end
  def votes
    object.rates.count
  end

  def group
    Api::V1::HomeGroupSerializer.new(object.owner, root: false) unless object.owner.nil?
  end

  def uploader
    Api::V1::HomeUserSerializer.new(object.uploader, root: false) unless object.uploader.nil?
  end
  def comments
    object.comments.count
  end
end
