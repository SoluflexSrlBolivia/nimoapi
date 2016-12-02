class NotificationNewCommentJob < ActiveJob::Base
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Do something with the exception

  end

  def perform(notification_message, devices, post)
    # Do something later
    Notification::send_notification notification_message, devices, {
        :type => Notification::NOTIFICATION_NEW_POST,
        :message => notification_message,
        :group_id => post.group.id,
        :post=>Api::V1::HomePostSerializer.new(post, root: false)
    }
  end
end
