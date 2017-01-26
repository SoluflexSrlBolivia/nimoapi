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

=begin
  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.updated_at
  end
=end

  def created_at
    object.created_at.strftime(I18n.t(:date_time_format)) if object.created_at
  end

  def updated_at
    object.updated_at.strftime(I18n.t(:date_time_format)) if object.updated_at
  end
end
