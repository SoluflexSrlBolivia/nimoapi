class Api::V1::HomeController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de novedades de un usuario"
  def index
  	group_ids = current_user.group_ids.join(',')
    puts ">>>>>>>>>>>>group_ids:#{group_ids}"
    recently_archives = []
    recently_posts = []
    unless group_ids.empty?
      recently_archives =Archive.where("owner_type = 'Group' AND owner_id IN (#{group_ids})").order(created_at: :desc).limit(10)
      recently_posts = Post.where("group_id IN (#{group_ids})").order(created_at: :desc).limit(10)
    end
  	
  	archives = ActiveModel::ArraySerializer.new(
      recently_archives,
      each_serializer: Api::V1::HomeArchiveSerializer
    )
    posts = ActiveModel::ArraySerializer.new(
      recently_posts,
      each_serializer: Api::V1::HomePostSerializer
    )
    
    render(
      json: {:archives=>archives, :posts=>posts}
    )
  end

  private

end