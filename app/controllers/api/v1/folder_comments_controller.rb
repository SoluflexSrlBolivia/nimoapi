class Api::V1::FolderCommentsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def show
    folder = Folder.find(params[:id])

    return api_error(status: 422) if folder.nil?

    comments = folder.comments.order(created_at: :desc)
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

  def create
    comment = Comment.new(create_params.merge({:commentable_type=>"Folder"}))
    authorize comment
    
    return api_error(status: 422, errors: comment.errors) unless comment.valid?

    comment.save!

    render(
      json: ActiveModel::ArraySerializer.new(
          comment.folder.comments,
          each_serializer: Api::V1::CommentSerializer,
          root: 'comments'
        ),
      status: 201
    )
  end

  def update
    comment = Comment.find(params[:id])
    authorize comment

    if !comment.update_attributes(update_params)
      return api_error(status: 422, errors: comment.errors)
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        comment.folder.comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        ),
      status: 200
    )
  end

  def destroy
    comment = Comment.find(params[:id])
    authorize comment

    if !comment.destroy
      return api_error(status: 500)
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        comment.folder.comments,
        each_serializer: Api::V1::CommentSerializer,
        root: 'comments',
        )
      status: 204
    )
  end

  private

  def create_params
    params.require(:comment).permit(
      :comment, :commentable_id
    ).delete_if{ |k,v| v.nil?}
  end
  def update_params
    create_params
  end

end