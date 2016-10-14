class Api::V1::DownloadSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :size, :content_type
  
  def id
  	object.archive.id
  end
  def name
  	object.archive.digital_file_name
  end
  def size
  	object.archive.digital_file_size
  end
  def content_type
  	object.archive.digital_content_type
  end
end
