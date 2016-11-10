class Api::V1::GroupsController < Api::V1::BaseController
  before_filter :authenticate_user!

  #########Files
  api! "listado de fotos de un group"
  def pictures
    group = Group.find(params[:id])
    
    return api_error(status: 422) if group.nil?

    archives = Archive.where("digital_content_type LIKE ? AND owner_type = ? AND owner_id = ?", "%image%", "Group", params[:id]).order(created_at: :desc)

    archives = apply_filters(archives, params.except(:id)) #it comming id and fail the filter, so is empty the result
    
    archives = paginate(archives)

    archives = policy_scope(archives)

    render(
      json: ActiveModel::ArraySerializer.new(
        archives,
        each_serializer: Api::V1::ArchiveSerializer,
        root: 'pictures',
        meta: meta_attributes(archives)
      )
    )
  end

  api! "listado de videos de un group"
  def videos
    group = Group.find(params[:id])
    
    return api_error(status: 422) if group.nil?

    archives = Archive.where("digital_content_type LIKE ? AND owner_type = ? AND owner_id = ?", "%video%", "Group", params[:id]).order(created_at: :desc)

    archives = apply_filters(archives, params.except(:id)) #it comming id and fail the filter, so is empty the result
    
    archives = paginate(archives)

    archives = policy_scope(archives)


    render(
      json: ActiveModel::ArraySerializer.new(
        archives,
        each_serializer: Api::V1::ArchiveSerializer,
        root: 'videos',
        meta: meta_attributes(archives)
      )
    )
  end

  api! "listado de audios de un group"
  def audios
    group = Group.find(params[:id])
    
    return api_error(status: 422) if group.nil?

    archives = Archive.where("digital_content_type LIKE ? AND owner_type = ? AND owner_id = ?", "%audio%", "Group", params[:id]).order(created_at: :desc)

    archives = apply_filters(archives, params.except(:id)) #it comming id and fail the filter, so is empty the result
    
    archives = paginate(archives)

    archives = policy_scope(archives)

    render(
      json: ActiveModel::ArraySerializer.new(
        archives,
        each_serializer: Api::V1::ArchiveSerializer,
        root: 'audios',
        meta: meta_attributes(archives)
      )
    )
  end

  api! "listado de archivos de un group"
  def g_archives
    group = Group.find(params[:id])
    
    return api_error(status: 422) if group.nil?

    archives = Archive.where("digital_content_type NOT LIKE ? AND digital_content_type NOT LIKE ? AND digital_content_type NOT LIKE ? AND owner_type = ? AND owner_id = ?", 
      "%image%", 
      "%video%",
      "%audio%",
      "Group", params[:id]).order(created_at: :desc)

    archives = apply_filters(archives, params.except(:id)) #it comming id and fail the filter, so is empty the result
    
    archives = paginate(archives)

    archives = policy_scope(archives)

    render(
      json: ActiveModel::ArraySerializer.new(
        archives,
        each_serializer: Api::V1::ArchiveSerializer,
        root: 'files',
        meta: meta_attributes(archives)
      )
    )
  end

  ######################################
  api! "busqueda de grupos"
  def search 
    result = Group.search(params[:q]).where(:deleted=>false).order(name: :asc)

    result = apply_filters(result, params)

    result = paginate(result)

    result = policy_scope(result)

    render(
      json: ActiveModel::ArraySerializer.new(
        result,
        each_serializer: Api::V1::GroupSerializer,
        root: 'groups',
        scope: {:current_user=>current_user},
        meta: meta_attributes(result)
      )
    )
  end

  api! "listado de groups de un usuario"
  def index
    groups = current_user.groups.where(:deleted=>false).order(name: :asc)
    groups = apply_filters(groups, params)

    groups = paginate(groups)

    groups = policy_scope(groups)

    render(
      json: ActiveModel::ArraySerializer.new(
        groups,
        each_serializer: Api::V1::GroupSerializer,
        root: 'groups',
        scope: {:current_user=>current_user},
        meta: meta_attributes(groups)
      )
    )
  end


  api! "detalle de un grupo"
  def show
    group = Group.find(params[:id])
    return api_error(status: 422) if group.deleted?

    authorize group

    render(
      json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user}).to_json
    )
  end


  api! "Creacion de un group"
  def create
    group = Group.new(create_params)
    group.admin_id = current_user.id
    group.users << current_user
    #authorize group

    if params[:digital] && digital_params[:data].present?
      archive = Archive.new(archive_params)
      archive.digital = digital_params[:data]
      group.archive = archive
    end

    return api_error(status: 422, errors: group.errors) unless group.valid?

    group.save!

    render(
      json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user}).to_json,
      status: 201,
      location: api_v1_group_path(group.id)
    )
  end

  api! "actulizacion de un grupo"
  def update
    group = Group.find(params[:id])
    authorize group

    if params[:digital] && digital_params[:data].present?
      group.archive.destroy! unless group.archive.nil?
      
      archive = Archive.new(archive_params)
      archive.digital = digital_params[:data]
      group.archive = archive
    end

    if !group.update_attributes(update_params)
      return api_error(status: 422, errors: group.errors)
    end

    render(
      json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user}).to_json,
      status: 200,
      location: api_v1_group_path(group.id)
    )
  end


  api! "Eliminacion de un grupo"
  def destroy
    group = Group.find(params[:id])
    authorize group

    if !group.delete_group
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
      params.require(:group).permit(
        :name, :description, :keyword, :privacity
      ).delete_if{ |k,v| v.nil?}
    end
    def update_params
      create_params
    end
end