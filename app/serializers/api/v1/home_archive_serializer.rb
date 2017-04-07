class Api::V1::HomeArchiveSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :size, :content_type, :rate, :alias, :group, :uploader, :comments, :votes, :created_at, :updated_at, :width, :height
  
  def name
  	object.original_file_name
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

  def alias
    return nil if object.alias.nil?

    aalias = Alias.find_by_name object.alias

    return Api::V1::AliasSerializer.new(aalias, root: false) unless aalias.nil?

    return {:name=>object.alias}
  end

  def width
    object.try(:image_width) || nil
  end
  def height
    object.try(:image_height) || nil
  end

end
