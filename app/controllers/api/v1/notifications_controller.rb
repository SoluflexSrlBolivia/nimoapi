class Api::V1::NotificationsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def index
  	notifications = current_user.notifications.order(id: :desc)
    notifications = apply_filters(notifications, params)

    notifications = paginate(notifications)

    notifications = policy_scope(notifications)

    render(
      json: ActiveModel::ArraySerializer.new(
        notifications,
        each_serializer: Api::V1::NotificationSerializer,
        root: 'notifications',
        meta: meta_attributes(notifications)
      )
    )
  end

  def update
  	notification = Notification.find params[:id]
    
    if !notification.update_attributes(update_params)
      return api_error(status: 422, errors: notification.errors)
    end

    action = eval notification.action
    unless action.nil?
    	requester_user = User.find action[:user]
    	group = Group.find action[:group]

    	if notification.notification_type == 3
    		noti_action = {:admin=>current_user.id, :group=>group.id}.to_s
        notification_ans = Notification.find_by_action noti_action
        if notification_ans.nil?
          notification_ans = Notification.new(
            :title=>"Solicitud Aceptada",
          	:message=>"#{current_user.notifier_name} acepto su ingreso al grupo:#{group.name}",
            :notification_type=>Notification::NOTIFICATION_TYPE_NORMAL_NEWS,
            :action=>noti_action
          )
          notification_ans.user = requester_user
          notification_ans.save!
          group.users << requester_user
          group.save!
          notification_ans.send_notification
          
        else
        	newuser = group.users.find_by_id requester_user.id
        	if newuser.nil?
        		group.users << requester_user
          	group.save!
        	end
        end
    	elsif notification.notification_type == 4
    		noti_action = {:admin=>current_user.id, :group=>group.id}.to_s
        notification_ans = Notification.find_by_action noti_action
        if notification_ans.nil?
          notification_ans = Notification.new(
            :title=>"Solicitud Rechazada",
          	:message=>"#{current_user.notifier_name} rechazo su ingreso al grupo:#{group.name}",
            :notification_type=>Notification::NOTIFICATION_TYPE_NORMAL_NEWS,
            :action=>noti_action
          )
          notification_ans.user = requester_user
          notification_ans.save!
          notification_ans.send_notification

        end
    	end
    end

    render(
      json: Api::V1::NotificationSerializer.new(notification).to_json,
      status: 200
    )
  end

  private
  	def update_params
  		params.require(:notification).permit(
        :notification_type #1:normal new, 2:request to acces to some group, 3:accepted, 4:rejected
      ).delete_if{ |k,v| v.nil?}
  	end
end