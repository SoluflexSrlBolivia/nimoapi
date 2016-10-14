class Api::V1::AliasSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :picture_id
  
  def picture_id
    object.archive.try(:id) || nil
  end
end
