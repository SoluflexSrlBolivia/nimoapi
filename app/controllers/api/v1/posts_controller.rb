class Api::V1::PostsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def_param_group :digital do
    param :digital, Hash, :required => true do
      param :data, String, :desc => "conteniado del archivo", :required => true
    end
  end
  def_param_group :archive do
    param :file, Hash, :required => true do
      param :owner_id, Fixnum, :desc => "ID Group propietario", :required => true
      param :owner_type, ["Group"], :desc => "\"Group\" tabla del propiertario(un post solo pertenece a un grupo)",  :required => true
      param :uploader_id, Fixnum, :desc => "ID del usuario q esta subiendo el archivo", :required => true
    end
  end
  def_param_group :create do
    param :post, Hash, :required => true do
      param :post, String, :desc => "el post", :required => true
      param :group_id, Fixnum, :desc => "ID Group",  :required => true
      param :user_id, Fixnum, :desc => "ID del usuario", :required => true
    end
  end

  def_param_group :paginate do
    param :locale, ["es", "en", "pt"], :desc => "es=español, en=ingles, pt=portugues", :required => false
    param :page, Integer, :desc => "# de pagina", :required => false
    param :per_page, Integer, :desc => "# de registros por pagina", :required => false
  end

  api! "Listado de post's de un group"
  param :id, Fixnum, :desc => "ID group", :required => true
  param_group :paginate
  def show
  	group = Group.find(params[:id])
  	#authorize group
    return api_error(status: 422) if group.nil?

    posts = group.posts.order(created_at: :desc)
    posts = apply_filters(posts, params.except(:id)) #it comming id and fail the filter, so is empty the result
    
    posts = paginate(posts)

    posts = policy_scope(posts)
    
    render(
      json: ActiveModel::ArraySerializer.new(
        posts,
        each_serializer: Api::V1::PostSerializer,
        root: 'posts',
        meta: meta_attributes(posts)
      )
    )
  end

  api! "Crear un post"
  param_group :create
  param_group :archive
  param_group :digital
  def create
    post = Post.new(create_params)
    authorize post
    
    if params[:digital] && digital_params[:data].present?
      archive = Archive.new(archive_params)
      archive.digital = digital_params[:data]
      post.archive = archive
    end

    return api_error(status: 422, errors: post.errors) unless post.valid?

    post.save!
    
    users_to_notify = post.group.users.where.not(:id=>create_params[:user_id]).where(:deleted=>false)
    if users_to_notify.count > 0
      notification_message = "#{current_user.notifier_name} acaba de postear al grupo:#{post.group.name}"

      users_to_notify.each do |user|
        notification = Notification.new(
          :message=>notification_message,
          :notification_type=>Notification::NOTIFICATION_NEW_POST
        )
        notification.user = user
        notification.save!
      end

      users_enabled = users_to_notify.select{|u| u.notification }.map{|u| u.id}
      user_to_push = post.group.user_groups.where(:user_id=>users_enabled).where(:notification=>true)
      devices = Device.where("user_id IN (#{user_to_push.map{|u| u.user_id}.join(",")})")
      devices = devices.map{|d| d.player_id}

      if devices.count>0
        Notification::send_notification notification_message, devices, {
            :type => Notification::NOTIFICATION_NEW_POST,
            :message => notification_message,
            :post=>Api::V1::HomePostSerializer.new(post, root: false)
        }
      end

    end

    render(
      json: Api::V1::PostSerializer.new(post).to_json,
      status: 201,
      location: api_v1_post_path(post.id)
    )
  end

  api! "Actulizacion de un post"
  param :id, Fixnum, :desc => "ID group", :required => true
  def update
    post = Post.find(params[:id])
    authorize post

    if !post.update_attributes(update_params)
      return api_error(status: 422, errors: post.errors)
    end

    render(
        json: Api::V1::PostSerializer.new(post).to_json,
        status: 201,
        location: api_v1_post_path(post.id)
    )
  end

  api! "Eliminacion de un post"
  param :id, Fixnum, :desc => "ID group", :required => true
  def destroy
    post = Post.find(params[:id])
    authorize post

    if !post.destroy
      return api_error(status: 500)
    end

    head status: 204
  end

  private
    def digital_params
      params.require(:digital).permit(
        :data
      ).delete_if{ |k,v| v.nil?}
    end
    def archive_params
      params.require(:file).permit(
        :owner_id, :owner_type, :uploader_id
      ).delete_if{ |k,v| v.nil?}
    end
    def create_params
      params.require(:post).permit(
        :post, :group_id, :user_id
      ).delete_if{ |k,v| v.nil?}
    end
    def update_params
      alias_params
    end
end