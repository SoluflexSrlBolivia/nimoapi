class Api::V1::HomeController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de novedades de un usuario"
  def index
  	group_ids = current_user.group_ids.join(',')

    recently_archives = []
    recently_posts = []
    unless group_ids.empty?
      recently_archives =Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").order(created_at: :desc).limit(10)
      recently_posts = Post.where("group_id IN (#{group_ids})").order(created_at: :desc).limit(10)
    end

    recents = recently_archives + recently_posts
    recents = apply_filters(recents, params)

    recents = paginate(recents)

    render(
      json: ActiveModel::ArraySerializer.new(
          recents,
          each_serializer: Api::V1::HomePostSerializer,
          root: 'recents',
          meta: meta_attributes(recents)
      )
    )
  end

  private

end