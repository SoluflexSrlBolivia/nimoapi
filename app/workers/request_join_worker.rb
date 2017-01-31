class RequestJoinWorker
  include Sidekiq::Worker

  def perform(devices, notification_id)
    notification = Notification.find notification_id

    result = Notification::send_notification notification.message, devices, {
        :type => Notification::NOTIFICATION_REQUEST_TO_JOIN_GROUP,
        :message => notification.message,
        :notification=>{:id => notification.id,
                        :notification_type => Notification::NOTIFICATION_REQUEST_TO_JOIN_GROUP,
                        :action => notification.action
        }
    }

    puts "request_to_join:#{result}"
  end
end
