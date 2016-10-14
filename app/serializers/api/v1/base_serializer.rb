class Api::V1::BaseSerializer < ActiveModel::Serializer

  def attributes
    hash = super
    hash.each do |key, value|
        if value.nil?
            hash.delete(key)
        end
    end
    hash
  end
  
  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.updated_at
  end
end
