class Api::V1::ArchiveCommentsController < Api::V1::BaseController
  before_filter :authenticate_user!

  api! "listado de comentarios de un archivo"
  def show
    archive = Archive.find(params[:id])
    
    return api_error(status: 422) if archive.nil?

    comments = archive.comments.order(created_at: :desc)
    comments = apply_filters(comments, params.except(:id)) #it comming id and fail the filter, so is empty the result
    
    comments = paginate(comments)

    comments = policy_scope(comments)
    
    render(
      json: ActiveModel::ArraySerializer.new(
        comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        meta: meta_attributes(comments)
      )
    )
  end

  api! "Creacion de comentario de un archivo"
  def create
    comment = Comment.new(create_params)
    #authorize comment
    
    return api_error(status: 422, errors: comment.errors) unless comment.valid?

    comment.user = current_user

    comment.save!

    render(
      json: Api::V1::CommentSerializer.new(comment).to_json,
      status: 201
    )
  end

  api! "Actulizacion de comentario de un archivo"
  def update
    comment = Comment.find(params[:id])
    authorize comment

    if !comment.update_attributes(update_params)
      return api_error(status: 422, errors: comment.errors)
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        comment.archive.comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        ),
      status: 200
    )
  end

  api! "eliminacion de comentario de un archivo"
  def destroy
    comment = Comment.find(params[:id])
    authorize comment

    if !comment.destroy
      return api_error(status: 500)
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        comment.archive.comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        ),
      status: 204
    )
  end

  private

  def create_params
    params.require(:comment).permit(
      :comment, :commentable_id, :commentable_type
    ).delete_if{ |k,v| v.nil?}
  end
  def update_params
    create_params
  end
end