class NewCommentWorker
  include Sidekiq::Worker

  def perform(notification_message, devices, post)
    # Do something later

    group = Group.find_by_id post.group_id
    result = Notification::send_notification notification_message, devices, {
        :type => Notification::NOTIFICATION_NEW_POST,
        :message => notification_message,
        :group_id => group.id,
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
