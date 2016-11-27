class Api::V1::ArchivesController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:create, :update, :destroy]

  def_param_group :create do
    param :file, Hash, :required => true do
      param :archivable_type, String, :required => true
      param :archivable_id, Fixnum, :required => true
      param :owner_id, Fixnum, :required => true
      param :owner_type, String, :required => true
      param :uploader_id, Fixnum, :required => true
    end
  end

  api! "Descarga un archivo original directo o por HTTP Range"
  param :id, Fixnum, :desc => "Archive ID", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  def show
  	archive = Archive.find(params[:id])

    return api_error(status: 404) if archive.nil?

    if request.headers["HTTP_RANGE"]
      send_file archive.digital.path, :range => true, type: archive.digital_content_type, :disposition => 'inline'
    else
      send_file archive.digital.path, :filename => archive.original_file_name, :type => archive.digital_content_type, :disposition => 'inline'
    end
  end

  api! "Descarga un archivo directo o por HTTP Range con el parametro scale para imagenes - full: '1024x1024>', medium: '800x800>', thumb: '400x400>',"+
  "Este servicio no devuelve el archivo original solo la imagen que lo representa, en el caso de foto o video devuelve el scale que se pide de existir."
  param :id, Fixnum, :desc => "Archive ID", :required => true
  param :scale, String, :desc => "Scale:full, medium, thumb", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  def scale
    archive = Archive.find(params[:id])

    return api_error(status: 404) if archive.nil?

    file_path = archive.digital.path(params[:scale])
    file_content_type = archive.is_video? ? archive.default_content_type : archive.digital_content_type
    unless File.exist?(file_path)
      file_path = archive.default_image_path
      file_content_type = archive.default_content_type
    end

    if request.headers["HTTP_RANGE"]
      send_file file_path, :range => true, type: file_content_type, :disposition => 'inline'
    else
      send_file file_path, :filename => archive.original_file_name, :type => file_content_type, :disposition => 'inline'
    end
  end

  api! "Solo descarga el archivo"
  param :id, Fixnum, :desc => "Archive ID", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  def download
  	archive = Archive.find(params[:id])

    return api_error(status: 404) if archive.nil?

  	send_file archive.digital.path, :filename => archive.original_file_name, :type => archive.digital_content_type, :disposition => 'downloaded'
  end

  api! "Crea un archivo"
  param_group :create
  def create
    archive = Archive.new(create_params)
    archive.digital = digital_params[:data]

  	return api_error(status: 422, errors: archive.errors) unless archive.valid?

    archive.save!

    render(
      json: Api::V1::ArchiveSerializer.new(archive).to_json,
      status: 201,
      location: api_v1_archive_path(archive.id)
    )
  end

  api! "Actuliza un archivo"
  param_group :create
  def update
    archive = Archive.find(params[:id])

    if params[:digital] && digital_params[:data].present?
      archive.digital = nil
      archive.save

      archive = Archive.new(archive_params)
      archive.digital = digital_params[:data]
    else
      return api_error(status: 422, errors: "Envie un archivo")
    end
    
    if !archive.update_attributes(update_params)
      return api_error(status: 422, errors: archive.errors)
    end

    render(
      json: Api::V1::ArchiveSerializer.new(archive).to_json,
      status: 200
    )
  end

  api! "Elimina un archivo"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  param :id, Fixnum, :desc => "Archive ID", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  def destroy
  	archive = Archive.find(params[:id])
    
    return api_error(status: 500) unless archive.uploader_id == current_user.id
    #check if the archive has a folder
    return api_error(status: 500) unless archive.archivable_type == "Folder"

    if !archive.destroy
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
  	def create_params
	    params.require(:file).permit(
	      :archivable_type, :archivable_id, :owner_id, :owner_type, :uploader_id
	    ).delete_if{ |k,v| v.nil?}
	  end
    def update_params
      create_params
    end



end