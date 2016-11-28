class Api::V1::AliasesController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de alias de un usuario"
  def index
    render(
      json: ActiveModel::ArraySerializer.new(
        current_user.aliases,
        each_serializer: Api::V1::AliasSerializer,
        root: 'aliases'
      )
    )
  end

  api! "Creacion de alias"
  def create
    aliass = Alias.new(create_params)

    if params[:digital] && digital_params[:data].present?
      archive = Archive.new(archive_params)
      archive.digital = digital_params[:data]
      aliass.archive = archive
    end

    return api_error(status: 422, errors: aliass.errors) unless aliass.valid?

    current_user.aliases << aliass
    current_user.save!

    render(
        json: Api::V1::AliasSerializer.new(aliass, root: 'alias').to_json,
        status: 201,
        location: api_v1_alias_path(aliass.id)
    )
  end

  api! "Actulizacion de alias"
  def update
    aliass = Alias.find(params[:id])
    authorize aliass

    if params[:digital] && digital_params[:data].present?
      aliass.archive.destroy unless aliass.archive.nil?
      
      archive = Archive.new(archive_params)
      archive.digital = digital_params[:data]
      aliass.archive = archive
    end

    if !aliass.update_attributes(update_params)
      return api_error(status: 422, errors: aliass.errors)
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        current_user.aliases,
        each_serializer: Api::V1::AliasSerializer,
        root: 'aliases',
        ),
      status: 200
    )
  end

  api! "Eliminacion de alias"
  def destroy
    aliass = Alias.find(params[:id])
    

    if !aliass.destroy
      return api_error(status: 500)
    end

    if current_user.alias_id == aliass.id
      current_user.alias_id = nil 
      current_user.save!
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        current_user.aliases,
        each_serializer: Api::V1::AliasSerializer,
        root: 'aliases'
        ),
      status: 200
    )
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
      params.require(:alias).permit(
        :name
      ).delete_if{ |k,v| v.nil?}
    end
    def update_params
      create_params
    end
end