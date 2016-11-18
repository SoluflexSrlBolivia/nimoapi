class Api::V1::HomeController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de novedades de un usuario"
  def index
  	group_ids = current_user.group_ids.join(',')

    unless group_ids.empty?
      recently_archives =Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").order(created_at: :desc)
      recently_posts = Post.where("group_id IN (#{group_ids})").order(created_at: :desc)

      recently_archives = apply_filters(recently_archives, params)
      recently_archives = paginate(recently_archives)

      recently_posts = apply_filters(recently_posts, params)
      recently_posts = paginate(recently_posts)

      archives = ActiveModel::ArraySerializer.new(
          recently_archives,
          each_serializer: Api::V1::HomeArchiveSerializer,
          root: "archives",
          meta: meta_attributes(recently_archives)
      )
      posts = ActiveModel::ArraySerializer.new(
          recently_posts,
          each_serializer: Api::V1::HomePostSerializer,
          root: "posts",
          meta: meta_attributes(recently_posts)
      )

      recents = Recent.new(posts, archives)

      return render(
          json: recents
      )
    end

    render json: {:posts=>[], :archives=>[]}
  end

  private

end