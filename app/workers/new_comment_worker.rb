class NewCommentWorker
  include Sidekiq::Worker

  def perform(notification_message, devices, post_id)
    # Do something later
    post = Post.find_by_id post_id
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
