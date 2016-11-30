class Api::V1::DownloadSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :size, :content_type, :alias
  
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
  def alias
    current_user = scope[:current_user]
    if current_user.present?
      return nil if object.archive.alias.nil?

      aalias = Alias.find_by_name object.archive.alias

      return Api::V1::AliasSerializer.new(aalias, root: false) unless aalias.nil?

      return {:name=>object.archive.alias}
    end
  end
end
