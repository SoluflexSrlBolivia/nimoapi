class RequestRejectedWorker
  include Sidekiq::Worker

  def perform(devices, notification_ans_id)
    notification_ans = Notification.find_by_id notification_ans_id

    Notification::send_notification notification_ans.message, devices, {
        :type => notification_ans.notification_type,
        :message => notification_ans.message
    }
  end
end
