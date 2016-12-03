class RequestAcceptedWorker
  include Sidekiq::Worker

  def perform(devices, notification_ans_id, group_id)
    notification_ans = Notification.find_by_id notification_ans_id
    group = Group.find_by_id group_id

    result = Notification::send_notification notification_ans.message, devices, {
        :type => notification_ans.notification_type,
        :message => notification_ans.message,
        :group_id=>group.id,
        :group=>Api::V1::HomeGroupSerializer.new(group, root: false)
    }

    puts "request accepted:#{result}"
  end
end
