class NotificationNewCommentJob < ActiveJob::Base
  queue_as :urgent

  # Just include the Mixin below and the perform_async method will be available
  include Sidekiq::Worker

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Do something with the exception

  end

  def perform(notification_message, devices, post)
    # Do something later
    result = Notification::send_notification notification_message, devices, {
        :type => Notification::NOTIFICATION_NEW_POST,
        :message => notification_message,
        :group_id => post.group.id,
        :post=>Api::V1::HomePostSerializer.new(post, root: false)
    }

    # Put the results in a redis list so we can see them on the web interface at each new request
    redis.rpush "new comment", result
  end

  # Create a redis client
  def redis
    @redis ||= Redis.new
  end
end
