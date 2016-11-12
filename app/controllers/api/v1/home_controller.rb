class Api::V1::HomeController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de novedades de un usuario"
  def index
  	group_ids = current_user.group_ids.join(',')

    recently_archives = []
    recently_posts = []
    unless group_ids.empty?
      recently_archives =Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").order(created_at: :desc)
      recently_posts = Post.where("group_id IN (#{group_ids})").order(created_at: :desc)
    end

    archives = apply_filters(recently_archives, params)
    archives = paginate(archives)

    posts = apply_filters(recently_posts, params)
    posts = paginate(posts)

    archives = ActiveModel::ArraySerializer.new(
        archives,
        each_serializer: Api::V1::HomeArchiveSerializer,
        root: false,
        meta: meta_attributes(archives)
    )
    posts = ActiveModel::ArraySerializer.new(
        posts,
        each_serializer: Api::V1::HomePostSerializer,
        root: false,
        meta: meta_attributes(archives)
    )

    recents = Recent.new(posts, archives)

    render(
      json: {recents:recents}
    )



=begin
    recents = Recent.new(recently_posts, recently_archives)
    recents = apply_filters(recents, params)
    recents = paginate(recents)

    render(
        json: ActiveModel::ArraySerializer.new(
            recents,
            each_serializer: Api::V1::HomeRecentSerializer,
            root: 'recents',
            meta: meta_attributes(recents)
        )
    )
=end
  end

  private

end