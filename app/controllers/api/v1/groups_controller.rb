class Api::V1::GroupsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def_param_group :create do
    param :group, Hash, :required => true do
      param :name, String, :desc => "Nombre del grupo",  :required => true
      param :description, String, :desc => "Descripcion del grupo"
      param :keyword, String, :desc => "contraseña de acceso, solo si privacity es de tipo 3"
      param :privacity, Fixnum, :desc => "#1=Abierto, 2=Cerrado, 3=Privado(keyword)",  :required => true
    end
  end


  #########Files
  api! "listado de fotos de un group"
  param :id, Fixnum, :desc => "ID Group",  :required => true
  param :locale, String, :desc => "idioma"
  param :page, Fixnum, :desc => "Pagina a cargar"
  param :per_page, :Fixnum, :desc => "numero de registros por pagina"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "Not found Group"
  example "Response" + '

'
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
  param :id, Fixnum, :desc => "ID Group",  :required => true
  param :locale, String, :desc => "idioma"
  param :page, Fixnum, :desc => "Pagina a cargar"
  param :per_page, :Fixnum, :desc => "numero de registros por pagina"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "Not found Group"
  example "Response" + '

  '
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
  param :id, Fixnum, :desc => "ID Group",  :required => true
  param :locale, String, :desc => "idioma"
  param :page, Fixnum, :desc => "Pagina a cargar"
  param :per_page, :Fixnum, :desc => "numero de registros por pagina"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "Not found Group"
  example "Response" + '

  '
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
  param :id, Fixnum, :desc => "ID Group",  :required => true
  param :locale, String, :desc => "idioma"
  param :page, Fixnum, :desc => "Pagina a cargar"
  param :per_page, :Fixnum, :desc => "numero de registros por pagina"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "Not found Group"
  example "Response" + '

  '
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
  param :q, String, :desc => "Criterio de busqueda",  :required => true
  param :locale, String, :desc => "idioma"
  param :page, Fixnum, :desc => "Pagina a cargar"
  param :per_page, :Fixnum, :desc => "numero de registros por pagina"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
       :url => "/api/v1/groups/fotos/search",
       :q => "fotos"
  error 401, "Bad credentials"
  error 403, "not authorized"
  example "Response" + '

  '
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
  param :locale, String, :desc => "idioma"
  param :page, Fixnum, :desc => "Pagina a cargar"
  param :per_page, :Fixnum, :desc => "numero de registros por pagina"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  example "Response" + '
{
  "groups": [
    {
      "id": 6,
      "name": "Boehm Group",
      "description": "Organic zero defect matrix",
      "keyword": "LeHoKj",
      "privacity": 3,
      "admin": {
        "id": 1,
        "email": "demo@gmail.com",
        "fullname": "Demo User",
        "name": "Demo User",
        "notification": true
      },
      "notification": true,
      "rate": 2,
      "member": 1,
      "my_rate": 5,
      "folder_id": 7
    },
    {
      "id": 3,
      "name": "Witting Inc",
      "description": "Multi-channelled responsive encryption",
      "privacity": 2,
      "admin": {
        "id": 1,
        "email": "demo@gmail.com",
        "fullname": "Demo User",
        "name": "Demo User",
        "notification": true
      },
      "notification": true,
      "rate": 4,
      "member": 1,
      "my_rate": 4,
      "folder_id": 4
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 9
  }
}
  '
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
  #param :id, Fixnum, :desc => "ID Group", :required => true
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "Not found Group"
  example "Response" + '

  '
  def show
    group = Group.find(params[:id])
    return api_error(status: 422) if group.deleted?

    authorize group

    render(
      json: Api::V1::GroupSerializer.new(group, :scope=>{:current_user=>current_user}).to_json
    )
  end


  api! "Creacion de un group"
  param_group :create
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "Not found Group"
  example "Response" + '

  '
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
  param :id, Fixnum, :desc => "ID Group",  :required => true
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 500, "No pudo borrar"
  example "Response" + '
  '
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
