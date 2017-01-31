class RequestJoinWorker
  include Sidekiq::Worker

  def perform(devices, notification_id, notification_action, notification_message)

    result = Notification::send_notification notification_message, devices, {
        :type => Notification::NOTIFICATION_REQUEST_TO_JOIN_GROUP,
        :message => notification_message
    }

    puts "request_to_join:#{result}"
  end
end
