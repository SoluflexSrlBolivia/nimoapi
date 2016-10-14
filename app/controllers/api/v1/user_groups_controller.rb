class Api::V1::UserGroupsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def members
  	group = Group.find(params[:id])

    return api_error(status: 422) if group.nil?
    #authorize group

    group_members = group.users.where(:deleted=>false).order(created_at: :desc)
    group_members = apply_filters(group_members, params.except(:id)) #it comming id and fail the filter, so is empty the result
    group_members = paginate(group_members)
    
    group_members = policy_scope(group_members)

    render(
      json: ActiveModel::ArraySerializer.new(
        group_members,
        each_serializer: Api::V1::MemberSerializer,
        root: 'members',
        meta: meta_attributes(group_members)
      )
    )
  end

  def show
    group = Group.find params[:id]

    return api_error(status: 422) if group.nil?

    render(
      json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user} ).to_json,
      status: 200
    )
  end

  def register_by_keyword
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    userGroup = group.user_groups.find_by_user_id current_user.id
    if userGroup.nil?
      return render(json: {:message=>"keyword invalido"}) unless group.keyword == register_params[:keyword]
      userGroup = UserGroup.new(:user_id=>current_user.id, :group_id=>group.id)
      userGroup.user = current_user
      userGroup.save!

      return render(
        json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user} ).to_json,
        status: 200
      )
    end
    
    render(json: {:message=>"Ya esta dentro del grupo"})
  end

  def add_alias
    alias_name = alias_params[:alias]
    return api_error(status: 422) if alias_name.empty?

    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    userGroup = group.user_groups.find_by_user_id current_user.id
    return api_error(status: 422) if userGroup.nil?

    if userGroup.alias == alias_name
      return render(
          json: {:status=>"fail", :message=>"Ya agrego ese alias"}
      )
    end

    userGroup.alias = alias_name
    userGroup.save

    return render(
        json: {:status=>"ok", :group=>Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user} , :root=>false)},
        status: 200
    )

  end

  def join
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    userGroup = group.user_groups.find_by_user_id current_user.id

    if userGroup.nil?
      if group.privacity == 1 #Publico
        userGroup = UserGroup.new(:user_id=>current_user.id, :group_id=>group.id)
        userGroup.user = current_user
        userGroup.save!

        return render(
          json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user} ).to_json,
          status: 200
        )
      elsif group.privacity == 2 #Cerrado, enviar solicitud
        action = {:user=>current_user.id, :group=>group.id}.to_s
        notification = Notification.find_by_action action
        if notification.nil?
          notification = Notification.new(
            :title=>"Solicitud de acceso a:#{group.name}",
            :message=>"#{current_user.notifier_name} solicita el ingreso al grupo:#{group.name}",
            :notification_type=>Notification::NOTIFICATION_TYPE_REQUEST_GROUP,
            :action=>action
          )
          notification.user = group.admin
          notification.save!
          notification.send_notification

        end

        return render(json: {:message=>"Se envio la solicitud al administrador del grupo"})
      elsif group.privacity == 3 #Privado, no hace nada
        return api_error(status: 422)
      end
    end

    render(json: {:message=>"Ya se envio la solicitud"})
  end
  def destroy
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?
    
    userGroup = group.user_groups.find_by_user_id params[:user_id]

    unless userGroup.nil?
      userGroup.destroy!
    end

    head status: 204
  end

  def update
    userGroup = UserGroup.find_by(:group_id=>params[:id], :user_id=>current_user)
    
    if !userGroup.update_attributes(group_params)
      return api_error(status: 422, errors: userGroup.errors)
    end

    render(
      json: Api::V1::GroupSerializer.new(userGroup.group, :scope=>{:current_user=>current_user} ).to_json,
      status: 200
    )
  end

  def add_members
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    all_user_ids = member_params[:member_ids]
    all_user_ids.map!{|n| n.to_i}
    all_user_ids << current_user.id unless all_user_ids.include?(current_user.id)
    user_ids_already = group.user_groups.where("user_id IN (#{all_user_ids.join(",")})").map{|ug| ug.user_id}
    new_user_ids = all_user_ids.select{|id| !user_ids_already.include?(id) }

    new_user_ids.each{|id| UserGroup.create(:user_id=>id, :group_id=>group.id)}

    render(
      json: {:status=>"ok"}
    )
  end

  private
	  def group_params
      params.require(:group).permit(
        :notification, :rate
      ).delete_if{ |k,v| v.nil?}
    end
    def member_params 
      params.require(:group).permit(
        member_ids: []
      ).delete_if{ |k,v| v.nil?}
    end
    def alias_params
      params.require(:group).permit(
          :alias
      ).delete_if{ |k,v| v.nil?}
    end
    def register_params
      params.require(:group).permit(
        :keyword
      ).delete_if{ |k,v| v.nil?}
    end
end