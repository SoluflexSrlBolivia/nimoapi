class Api::V1::NotificationSerializer < Api::V1::BaseSerializer
  attributes :id, :message, :notification_type, :action

  def notification_type
    object.try(:notification_type)
  end
  
end
