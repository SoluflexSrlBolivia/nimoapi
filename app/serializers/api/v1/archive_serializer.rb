class Api::V1::ArchiveSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :size, :content_type, :uploader, :rate, :alias, :width, :height
  
  def uploader
  	Api::V1::UserArchiveSerializer.new(object.uploader, root: false) unless object.uploader.nil?
  end

  def name
    if object.original_file_name.nil? || object.original_file_name.empty?
      object.digital_file_name
    else
      object.original_file_name
    end
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
