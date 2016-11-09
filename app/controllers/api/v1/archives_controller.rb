class Api::V1::ArchivesController < Api::V1::BaseController
  before_filter :authenticate_user!#, only: [:create, :update, :destroy]

  api! "Descarga un archivo directo o por HTTP Range"
  def show
  	archive = Archive.find(params[:id])
    if request.headers["HTTP_RANGE"]
      send_file archive.digital.path, :range => true, type: archive.digital_content_type, :disposition => 'inline'
    else
      send_file archive.digital.path, :filename => archive.original_file_name, :type => archive.digital_content_type, :disposition => 'inline'
    end
  end

  api! "Descarga un archivo directo o por HTTP Range con el parametro scale para imagenes - medium(500x500), thumb(200x200)"
  def scale
    archive = Archive.find(params[:id])
    if request.headers["HTTP_RANGE"]
      send_file archive.digital.path(params[:scale]), :range => true, type: archive.digital_content_type, :disposition => 'inline'
    else
      send_file archive.digital.path(params[:scale]), :filename => archive.original_file_name, :type => archive.digital_content_type, :disposition => 'inline'
    end
  end

  api! "Solo descarga el archivo"
  def download
  	archive = Archive.find(params[:id])
  	send_file archive.digital.path, :filename => archive.original_file_name, :type => archive.digital_content_type, :disposition => 'downloaded'
  end

  api! "Crea un archivo"
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