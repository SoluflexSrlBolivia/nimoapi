class NewCommentWorker
  include Sidekiq::Worker

  def perform(notification_message, devices, commentable_type, commentable_id, comment_id)
    # Do something

    result = Notification::send_notification notification_message, devices, {
        :type => Notification::NOTIFICATION_NEW_COMMENT,
        :commentable_type => commentable_type,
        :commentable_id => commentable_id,
        :comment_id => comment_id
    }

    puts "new comment:#{result}"
  end


end
