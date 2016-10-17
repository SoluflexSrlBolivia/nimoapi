class Api::V1::PostCommentsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def show
    post = Post.find(params[:id])
    
    return api_error(status: 422) if post.nil?

    comments = post.comments.order(created_at: :desc)
    comments = apply_filters(comments, params.except(:id)) #it comming id and fail the filter, so is empty the result

    comments = paginate(comments)

    comments = policy_scope(comments)

    render(
      json: ActiveModel::ArraySerializer.new(
        comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        meta: meta_attributes(comments)
      )
    )
  end

  def create
    comment = Comment.new(create_params)
    #authorize comment
    
    return api_error(status: 422, errors: comment.errors) unless comment.valid?
    
    comment.user = current_user

    comment.save!

    users_to_notify = []
    group = nil
    if comment.commentable.kind_of?(Post)
      users_to_notify = comment.commentable.group.users.where.not(:id=>current_user.id).where(:deleted=>false)
      group = comment.commentable.group
    elsif comment.commentable.kind_of?(Archive) && comment.commentable.owner.kind_of?(Group)
      users_to_notify = comment.commentable.owner.users.where.not(:id=>current_user.id).where(:deleted=>false)
      group = comment.commentable.owner
    end
    
    if users_to_notify.count > 0
      notification_message = "Nuevo commentario de:#{current_user.notifier_name}"
      users_to_notify.each do |user|
        notification = Notification.new(
          :message=>notification_message,
          :notification_type=>Notification::NOTIFICATION_NEW_COMMENT
        )
        notification.user = user
        notification.save!
      end
      
      users_enabled = users_to_notify.select{|u| u.notification }.map{|u| u.id}
      user_to_push = group.user_groups.where(:user_id=>users_enabled).where(:notification=>true)
      devices = Device.where("user_id IN (#{user_to_push.map{|u| u.user_id}.join(",")})")
      devices = devices.map{|d| d.player_id}

      if devices.count>0
        Notification::send_notification notification_message, devices, {
            :type => Notification::NOTIFICATION_NEW_COMMENT,
            :message => notification_message,
            :comment=>Api::V1::CommentSerializer.new(comment, root: false)
        }
      end

    end

    render(
      json: Api::V1::CommentSerializer.new(comment).to_json,
      status: 201
    )
  end

  def update
    comment = Comment.find(params[:id])
    authorize comment

    if !comment.update_attributes(update_params)
      return api_error(status: 422, errors: comment.errors)
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        comment.post.comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        ),
      status: 200
    )
  end

  def destroy
    comment = Comment.find(params[:id])
    authorize comment

    if !comment.destroy
      return api_error(status: 500)
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        comment.post.comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        ),
      status: 204
    )
  end

  private

  def create_params
    params.require(:comment).permit(
      :comment, :commentable_id, :commentable_type
    ).delete_if{ |k,v| v.nil?}
  end
  def update_params
    create_params
  end

end