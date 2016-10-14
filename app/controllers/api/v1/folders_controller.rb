class Api::V1::FoldersController < Api::V1::BaseController
  before_filter :authenticate_user!

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
