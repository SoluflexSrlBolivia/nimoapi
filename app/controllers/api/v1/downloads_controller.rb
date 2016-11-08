class Api::V1::DownloadsController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "Crear descarga en el folder de un usuario"
  def create
    download = Download.new(create_params)
    
  	return api_error(status: 422, errors: download.errors) unless download.valid?

    download.save!

    render(
      json: Api::V1::DownloadSerializer.new(download).to_json,
      status: 201,
      location: api_v1_archive_path(download.archive.id)
    )
  end

  api! "Eliminacion de un download de un usuario"
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
