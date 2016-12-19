class Api::V1::DownloadsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def_param_group :create do
    param :file, Hash, :required => true do
      param :owner_id, Fixnum, :desc => "ID User propietario", :required => true
      param :owner_type, ["User"], :desc => "\"User\" tabla del propiertario", :required => true
      param :folder_id, Fixnum, :desc => "ID del folder donde se guardara donde se guardara el archivo", :required => true
      param :archive_id, Fixnum, :desc => "ID del archivo a guardar", :required => true
    end
  end

  api! "Crear descarga en el folder de un usuario"
  param_group :create
  def create
    download = Download.new(create_params)
    
  	return api_error(status: 422, errors: download.errors) unless download.valid?

    download.save!

    render(
      json: Api::V1::DownloadSerializer.new(download, scope: {:current_user=>current_user}).to_json,
      status: 201,
      location: api_v1_archive_path(download.archive.id)
    )
  end

  api! "Eliminacion de un download(referencia de una archivo) de un usuario"
  param :id, Fixnum, :desc => "ID Download item", :required => true
  param :folder_id, Fixnum, :desc => "ID Folder donde se encuentra el download item", :required => true
  def destroy
  	archive = Download.find_by(:archive_id=>params[:id], :folder_id=>params[:folder_id])
    
    if !archive.destroy
      return api_error(status: 500)
    end

    head status: 204
  end

  private
    def create_params
	    params.require(:file).permit(
	      :owner_id, :owner_type, :folder_id, :archive_id
	    ).delete_if{ |k,v| v.nil?}
	  end

end
