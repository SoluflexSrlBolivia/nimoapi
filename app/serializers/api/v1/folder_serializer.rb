class Api::V1::FolderSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :description#, :folder_id
  
  #has_many :folders

  #def folder_id
  #	object.folderable_id
  #end

end
