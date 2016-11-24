class Api::V1::FoldersController < Api::V1::BaseController
  before_filter :authenticate_user!

  def_param_group :search do
    param :search, Hash, :required => true do
      param :name, String, :desc => "\"User\" tabla propietaria del folder, en este caso es el usuario ",  :required => true
      param :id, Fixnum, :desc => "ID User",  :required => true
    end
  end

  def_param_group :create do
    param :folder, Hash, :required => true do
      param :name, String, :desc => "Nombre del folder"
      param :folder_id, Fixnum, :desc => "ID Folder, tabla padre(Folder es recursivo, todo folder tiene padre excepto el root)",  :required => true
      param :description, String, :desc => "Descripcion"
      param :owner_id, Fixnum, :desc => "ID User propietario del folder",  :required => true
      param :owner_type, String, :desc => "\"User\" propietario del folder",  :required => true
    end
  end

  api! "Busqueda de carpetas"
  param_group :search
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
       :url => "/api/v1/folders/fotos/search",
       :q => "fotos"
  error 401, "Bad credentials"
  error 403, "not authorized"
  example "Response" + '
{
  "folders": [],
  "archives": [],
  "downloads": []
}
'
  def search 
    resultFolders = Folder.search(params[:q]).where(:owner_type=>search_params[:name], :owner_id => search_params[:id])
    resultArchives = Archive.search(params[:q]).where(:owner_type=>search_params[:name], :owner_id => search_params[:id])
    resultDownloads = Download.search(params[:q]).where(:owner_type=>search_params[:name], :owner_id => search_params[:id])

    archives = ActiveModel::ArraySerializer.new(
      resultArchives,
      each_serializer: Api::V1::ArchiveSerializer
    )
    folders = ActiveModel::ArraySerializer.new(
      resultFolders,
      each_serializer: Api::V1::FolderSerializer
    )
    downloads = ActiveModel::ArraySerializer.new(
      resultDownloads,
      each_serializer: Api::V1::DownloadSerializer
    )

    render(
      json: {:folders=>folders, :archives=>archives, :downloads=>downloads}
    )
  end

  api! "listado de carpetas y archivos del folder de un usuario"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  example "Response" + '
{
  "folders": [],
  "archives": [],
  "downloads": []
}
'
  def index
    archives = ActiveModel::ArraySerializer.new(
      current_user.folder.archives,
      each_serializer: Api::V1::ArchiveSerializer
    )
    folders = ActiveModel::ArraySerializer.new(
      current_user.folder.folders,
      each_serializer: Api::V1::FolderSerializer
    )
    downloads = ActiveModel::ArraySerializer.new(
      current_user.folder.downloads,
      each_serializer: Api::V1::DownloadSerializer
    )

    render(
      json: {:folders=>folders, :archives=>archives, :downloads=>downloads}
    )
  end

  api! "listado de carpetas y archivos de una carpeta"
  param :id, Fixnum, :desc => "ID Folder",  :required => true
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  example "Response" + '
{
  "folders": [],
  "archives": [],
  "downloads": []
}
'
  def show
    folder = Folder.find(params[:id])
    authorize folder

    archives = ActiveModel::ArraySerializer.new(
      folder.archives,
      each_serializer: Api::V1::ArchiveSerializer
    )
    folders = ActiveModel::ArraySerializer.new(
      folder.folders,
      each_serializer: Api::V1::FolderSerializer
    )
    downloads = ActiveModel::ArraySerializer.new(
      folder.downloads,
      each_serializer: Api::V1::DownloadSerializer
    )
    
    render(
      json: {:folders=>folders, :archives=>archives, :downloads=>downloads}
    )
  end

  api! "Creacion de una carpeta"
  param_group :create
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  example "Response" + '
{
  "folders": [],
  "archives": [],
  "downloads": []
}
'
  def create
    new_params = create_params.merge(:folderable_type=>"Folder", :folderable_id=>create_params[:folder_id])
    new_params = new_params.except!(:folder_id)
    folder = Folder.new(new_params)
    authorize folder
    
    return api_error(status: 422, errors: folder.errors) unless folder.valid?

    folder.save!

    render(
      json: Api::V1::FolderSerializer.new(folder).to_json,
      status: 201,
      location: api_v1_folder_path(folder.id)
    )
  end

  api! "actulizacion de una carpeta"
  def update
    folder = Folder.find(params[:id])
    authorize folder

    if !folder.update_attributes(update_params)
      return api_error(status: 422, errors: folder.errors)
    end

    render(
      json: Api::V1::FolderSerializer.new(folder).to_json,
      status: 200,
      location: api_v1_folder_path(folder.id)
    )
  end


  api! "eliminacion de una carpeta"
  param :id, Fixnum, :desc => "ID Folder",  :required => true
  def destroy
    folder = Folder.find(params[:id])
    authorize folder

    if !folder.destroy
      return api_error(status: 500)
    end

    head status: 204
  end

  private
    def create_params
      params.require(:folder).permit(
        :name, :description, :folder_id, :owner_id, :owner_type
      ).delete_if{ |k,v| v.nil?}
    end
    def update_params
      create_params
    end
    def search_params
      params.require(:search).permit(
        :name, :id
      ).delete_if{ |k,v| v.nil?}
    end
end
