class Api::V1::ArchiveSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :size, :content_type, :uploader, :rate
  
  def uploader
  	Api::V1::UserArchiveSerializer.new(object.uploader, root: false) unless object.uploader.nil?
  end

  def name
    return object.original_file_name if object.original_file_name.nil? || object.original_file_name.empty?
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

end
