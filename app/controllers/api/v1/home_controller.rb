class Api::V1::HomeController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de novedades de un usuario"
  def index
  	group_ids = current_user.group_ids.join(',')

    recently_archives = []
    recently_posts = []
    unless group_ids.empty?
      #recently_archives =Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").order(created_at: :desc)
      #recently_posts = Post.where("group_id IN (#{group_ids})").order(created_at: :desc)

      if params[:per_page]
        recently_archives = Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").paginate(:page => params[:page] || 1, :per_page => params[:per_page]).order(created_at: :desc)
        recently_posts = Post.where("group_id IN (#{group_ids})").paginate(:page => params[:page] || 1, :per_page => params[:per_page]).order(created_at: :desc)
      else
        recently_archives = Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").paginate(:page => params[:page] || 1).order(created_at: :desc)
        recently_posts = Post.where("group_id IN (#{group_ids})").paginate(:page => params[:page] || 1).order(created_at: :desc)
      end
    end

    #archives = apply_filters(recently_archives, params)
    #archives = paginate(archives)

    #posts = apply_filters(recently_posts, params)
    #posts = paginate(posts)

    archives = ActiveModel::ArraySerializer.new(
        archives,
        each_serializer: Api::V1::HomeArchiveSerializer,
        root: "archives",
        meta: meta_attributes(archives)
    )
    posts = ActiveModel::ArraySerializer.new(
        posts,
        each_serializer: Api::V1::HomePostSerializer,
        root: "posts",
        meta: meta_attributes(posts)
    )

    recents = Recent.new(posts, archives)

    render(
      json: recents
    )

  end

  private

end