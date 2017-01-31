class RequestJoinWorker
  include Sidekiq::Worker

  def perform(devices, notification_id)
    notification = Notification.find notification_id

    result = Notification::send_notification notification.message, devices, {
        :type => notification.notification_type,
        :message => notification.message,
        :notification=>Api::V1::NotificationSerializer.new(notification, root: false)
    }

    puts "request_to_join:#{result}"
  end
end
