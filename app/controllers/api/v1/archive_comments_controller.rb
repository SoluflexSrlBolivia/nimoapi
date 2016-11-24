class Api::V1::ArchiveCommentsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def_param_group :create do
    param :comment, Hash, :required => true do
      param :comment, String, :desc => "Comentario",  :required => true
      param :commentable_id, Fixnum, :desc => "Archive ID", :required => true
      param :commentable_type, String, :desc => "\"Archive\" tabla propietaria del comentario", :required => true
    end
  end

  def_param_group :update do
    param :comment, Hash, :required => true do
      param :comment, String, :desc => "Comentario",  :required => true
    end
  end

  api! "listado de comentarios de un archivo"
  param :id, Fixnum, :desc => "Archive ID", :required => true
  param :locale, String, :desc => "idioma"
  param :page, Fixnum, :desc => "Pagina a cargar"
  param :per_page, :Fixnum, :desc => "numero de registros por pagina"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "API Error"
  example "Response" + '
{
  "comments": [
    {
      "id": 18,
      "comment": "Hola archivo",
      "user": {
        "id": 1,
        "email": "demo@gmail.com",
        "fullname": "Demo User"
      },
      "created_at": "2016-11-24T19:03:59Z",
      "updated_at": "2016-11-24T19:03:59Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 1
  }
}
'
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
  param_group :create
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "API Error"
  example "Response" + '
{
  "comment": {
    "id": 17,
    "comment": "Hola archivo",
    "user": {
      "id": 1,
      "email": "demo@gmail.com",
      "fullname": "Demo User"
    },
    "created_at": "2016-11-24T19:02:15Z",
    "updated_at": "2016-11-24T19:02:15Z"
  }
}
'
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
  param :id, String, :desc => "Comment id", :required => true
  param_group :update
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 422, "API Error"
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
  param :id, String, :desc => "Comment id", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 500, "API Error"
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