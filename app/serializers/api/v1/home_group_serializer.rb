class Api::V1::HomeGroupSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :description, :archive_id
  
  def archive_id
  	object.archive.try(:id) || nil
  end

end
