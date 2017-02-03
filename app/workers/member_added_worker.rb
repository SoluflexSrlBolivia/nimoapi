class MemberAddedWorker
  include Sidekiq::Worker

  def perform(devices, notification_message)
    # Do something later
    result = Notification::send_notification notification_message, devices, {
        :type => Notification::NOTIFICATION_MEMBER_ADDED_TO_GROUP,
        :message => notification_message
    }

    puts "new post:#{result}"
  end
end