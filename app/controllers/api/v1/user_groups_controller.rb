class Api::V1::UserGroupsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def_param_group :group do
    param :group, Hash, :required => true do
      param :notification, [true, false], :desc => "abilitar/desabilitar notificacion del grupo",:required => true
      param :rate, [1,2,3,4,5], :desc => "valoracion del grupo entre 1 - 5", :required => true
    end
  end

  def_param_group :member do
    param :group, Hash, :required => true do
      param :member_ids, [Integer], :desc => "ID de los miembros(User)", :required => true
    end
  end

  def_param_group :alias do
    param :group, Hash, :required => true do
      param :alias, String, :desc => "alias", :required => true
    end
  end

  def_param_group :register do
    param :group, Hash, :required => true do
      param :keyword, String, :desc => "password del grupo", :required => true
    end
  end

  api! "Lista de miembros de mi grupo con MemberSerializer"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
       :url => "/api/v1/user_groups/:1/members",
       :id => "1"
  param :id, String, :desc => "Group ID", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "No existe el grupo"
  example "Response" + '
{
  "members": [
    {
      "id": 1,
      "email": "demo@gmail.com",
      "fullname": "Demo User",
      "notification": true
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 1
  }
}
'
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
        scope: {:group=>group},
        root: 'members',
        meta: meta_attributes(group_members)
      )
    )
  end

  api! "Detalle de un grupo con GroupSerializer"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
       :url => "/api/v1/user_groups/:1",
       :id => "1"
  param :id, String, :desc => "Group ID", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "No existe el grupo"
  example "Response" + '
{
  "group": {
    "id": 1,
    "name": "Bins, Maggio and Corwin",
    "description": "Phased scalable artificial intelligence",
    "keyword": "PeR149",
    "privacity": 3,
    "admin": {
      "id": 1,
      "email": "demo@gmail.com",
      "fullname": "Demo User",
      "name": "Demo User",
      "notification": true
    },
    "notification": true,
    "rate": 1,
    "member": 1,
    "my_rate": 1,
    "folder_id": 2
  }
}
'
  def show
    group = Group.find params[:id]

    return api_error(status: 422) if group.nil?

    render(
      json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user} ).to_json,
      status: 200
    )
  end

  api! "Registro de usuario a un grupo con contraseña - GroupSerializer"
  param_group :register
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
       :url => "/api/v1/user_groups/:1/keyword",
       :id => "1"
  param :id, String, :desc => "Group ID", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "No existe el grupo"
  example "Response" + '
{"message":"Ya esta dentro del grupo"}
------------------------
{"message":"keyword invalido"}
------------------------
{
  "group": {
    "id": 1,
    "name": "Bins, Maggio and Corwin",
    "description": "Phased scalable artificial intelligence",
    "keyword": "PeR149",
    "privacity": 3,
    "admin": {
      "id": 1,
      "email": "demo@gmail.com",
      "fullname": "Demo User",
      "name": "Demo User",
      "notification": true
    },
    "notification": true,
    "rate": 0,
    "member": 1,
    "my_rate": 0,
    "folder_id": 2
  }
}
'
  def register_by_keyword
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    userGroup = group.user_groups.find_by_user_id current_user.id
    if userGroup.nil?
      return render(json: {:message=>t(:keyword_invalid)}) unless group.keyword == register_params[:keyword]
      userGroup = UserGroup.new(:user_id=>current_user.id, :group_id=>group.id)
      userGroup.user = current_user
      userGroup.save!

      return render(
        json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user} ).to_json,
        status: 200
      )
    end
    
    render(json: {:message=>t(:already_in_group)})
  end

  api! "Adicion de alias a un grupo"
  param_group :alias
  def add_alias
    alias_name = alias_params[:alias]
    return api_error(status: 422) if alias_name.empty?

    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    userGroup = group.user_groups.find_by_user_id current_user.id
    return api_error(status: 422) if userGroup.nil?

    if userGroup.alias == alias_name
      return render(
          json: {:status=>"fail", :message=>t(:alias_exist)}
      )
    end

    userGroup.alias = alias_name
    userGroup.save

    return render(
        json: {:status=>"ok", :group=>Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user} , :root=>false)},
        status: 200
    )

  end

  api! "Solicitud de ingreso a un grupo"
  param :id, Fixnum, :desc => "ID Group", :required => true
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
            :message=>"#{current_user.notifier_name} #{t(:request_to_join)}:#{group.name}",
            :notification_type=>Notification::NOTIFICATION_REQUEST_TO_JOIN_GROUP,
            :action=>action
          )
          notification.user = group.admin
          notification.save!
        end

        users_enabled = [notification.user].select{|u| u.notification }.map{|u| u.id}
        user_to_push = group.user_groups.where(:user_id=>users_enabled).where(:notification=>true)
        devices = Device.where("user_id IN (#{user_to_push.map{|u| u.user_id}.join(",")})")
        devices = devices.map{|d| d.player_id}

        if devices.count > 0
          RequestJoinWorker.perform_async(devices, notification.id, notification.action, notification.message)
        end

        return render(json: {:message=>t(:request_sent_to_admin)})
      elsif group.privacity == 3 #Privado, no hace nada
        return api_error(status: 422)
      end
    end

    render(json: {:message=>t(:request_already_sended)})
  end

  api! "Salir de un grupo"
  param :id, Fixnum, :desc => "ID Group", :required => true
  def destroy
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?
    
    userGroup = group.user_groups.find_by_user_id params[:user_id]

    unless userGroup.nil?
      userGroup.destroy!
    end

    head status: 204
  end

  api! "Actulizacion de grupo"
  param :id, Fixnum, :desc => "ID Group", :required => true
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

  api! "Agregar miembro al grupo"
  param_group :member
  def add_members
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    all_user_ids = member_params[:member_ids]
    all_user_ids.map!{|n| n.to_i}
    all_user_ids << current_user.id unless all_user_ids.include?(current_user.id)
    user_ids_already = group.user_groups.where("user_id IN (#{all_user_ids.join(",")})").map{|ug| ug.user_id}
    new_user_ids = all_user_ids.select{|id| !user_ids_already.include?(id) }

    new_user_ids.each{|id| UserGroup.create(:user_id=>id, :group_id=>group.id)}

    ############
    if new_user_ids.count > 0
      notification_message = "#{t(:add_member_to_group)}: #{group.name}"
      new_user_ids.each do |user_id|
        notification = Notification.new(
            :message=>notification_message,
            :notification_type=>Notification::NOTIFICATION_MEMBER_ADDED_TO_GROUP
        )
        notification.user_id = user_id
        notification.save!
      end

      user_to_push = group.user_groups.where("user_id IN (#{new_user_ids.join(",")})").where(:notification=>true)
      devices = Device.where("user_id IN (#{user_to_push.map{|u| u.user_id}.join(",")})")
      devices = devices.map{|d| d.player_id}

      if devices.count > 0
        MemberAddedWorker.perform_async(devices, notification_message)
      end
    end
    ############

    render(
      json: {:status=>"ok"}
    )
  end

  api! "Agregar miembro al grupo, android"
  param_group :member
  def add_members_android
    group = Group.find params[:id]
    return api_error(status: 422) if group.nil?

    all_user_ids = member_params_android[:member_ids].split(",")
    all_user_ids.map!{|n| n.to_i}
    all_user_ids << current_user.id unless all_user_ids.include?(current_user.id)
    user_ids_already = group.user_groups.where("user_id IN (#{all_user_ids.join(",")})").map{|ug| ug.user_id}
    new_user_ids = all_user_ids.select{|id| !user_ids_already.include?(id) }

    new_user_ids.each{|id| UserGroup.create(:user_id=>id, :group_id=>group.id)}

    ############
    if new_user_ids.count > 0
      notification_message = "#{t(:add_member_to_group)}: #{group.name}"
      new_user_ids.each do |user_id|
        notification = Notification.new(
            :message=>notification_message,
            :notification_type=>Notification::NOTIFICATION_MEMBER_ADDED_TO_GROUP
        )
        notification.user_id = user_id
        notification.save!
      end

      user_to_push = group.user_groups.where("user_id IN (#{new_user_ids.join(",")})").where(:notification=>true)
      devices = Device.where("user_id IN (#{user_to_push.map{|u| u.user_id}.join(",")})")
      devices = devices.map{|d| d.player_id}

      if devices.count > 0
        MemberAddedWorker.perform_async(devices, notification_message)
      end
    end
    ############

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
    def member_params_android
      params.require(:group).permit(
        :member_ids
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