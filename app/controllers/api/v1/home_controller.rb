class Api::V1::HomeController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de novedades de un usuario"
  def index
  	group_ids = current_user.group_ids.join(',')

    unless group_ids.empty?
      recently_archives =Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").order(created_at: :desc)
      recently_posts = Post.where("group_id IN (#{group_ids})").order(created_at: :desc)

      archives_from_post = recently_posts.reject{|p| p.archive.nil? }.map{|p| p.archive.id }
      recently_archives = recently_archives.reject{|a| archives_from_post.include?(a.id) }

      recently_archives = apply_filters(recently_archives, params) unless recently_archives.empty?
      recently_archives = paginate(recently_archives) unless recently_archives.empty?

      recently_posts = apply_filters(recently_posts, params) unless recently_posts.empty?
      recently_posts = paginate(recently_posts) unless recently_posts.empty?


      meta_empty = {
          current_page: 1,
          next_page: nil,
          prev_page: nil,
          total_pages: 1,
          total_count: 0
      }

      archives = ActiveModel::ArraySerializer.new(
          recently_archives,
          each_serializer: Api::V1::HomeArchiveSerializer,
          root: "archives",
          meta: recently_archives.empty?? meta_empty : meta_attributes(recently_archives)
      )
      posts = ActiveModel::ArraySerializer.new(
          recently_posts,
          each_serializer: Api::V1::HomePostSerializer,
          root: "posts",
          meta: recently_posts.empty?? meta_empty : meta_attributes(recently_posts)
      )

      recents = Recent.new(posts, archives)

      return render(
          json: recents
      )
    end

    render json: {:posts=>{:posts=>[], :meta=>{
        current_page: 1,
        next_page: nil,
        prev_page: nil,
        total_pages: 1,
        total_count: 0
    }}, :archives=>{:archives=>[], :meta=>{
        current_page: 1,
        next_page: nil,
        prev_page: nil,
        total_pages: 1,
        total_count: 0
    }}}
  end

  private

end