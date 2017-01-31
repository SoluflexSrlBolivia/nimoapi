class Api::V1::NotificationSerializer < Api::V1::BaseSerializer
  attributes :id, :message, :notification_type, :action

end
