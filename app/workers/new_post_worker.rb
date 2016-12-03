class NewPostWorker
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

    puts "new post:#{result}"
  end
end
