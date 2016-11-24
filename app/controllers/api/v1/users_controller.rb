class Api::V1::UsersController < Api::V1::BaseController
  before_filter :authenticate_user!, :except => [:create]

  def_param_group :create do
    param :user, Hash, :required => true do
      param :email, String, :required => true
      param :password, String, :required => true
      param :password_confirmation, String, :required => true
    end
  end
  def_param_group :update do
    param :user, Hash, :required => true do
      param :email, String
      param :password, Hash
      param :password_confirmation, Hash
      param :name, String
      param :lastname, String
      param :gender, String
      param :birthday, String
      param :occupation, String
      param :phone_number, String
      param :country, String
      param :subregion, String
      param :alias_id, Fixnum
      param :notification, [true, false]
      param :deleted, [true, false]
    end
  end

  def_param_group :paginate do
    param :locale, ["es", "en", "pt"], :desc => "es=español, en=ingles, pt=portugues", :required => false
    param :page, Integer, :desc => "# de pagina", :required => false
    param :per_page, Integer, :desc => "# de registros por pagina", :required => false
  end

  api! "Busqueda de usuarios con UserSearchSerializer"
  param :q, String, :desc => "Criterio de busqueda", :required => true
  param_group :paginate
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
  :url => "/api/v1/users/ar/search",
  :q => "ar"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  example "Response" + '
{
  "users": [
    {
      "id": 61,
      "email": "arjun@yahoo.com",
      "fullname": "Arjun",
      "name": "Arjun"
    },
    {
      "id": 72,
      "email": "arlie@yahoo.com",
      "fullname": "Arlie",
      "name": "Arlie"
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 2
  }
}'
  def search
    result = User.search(params[:q]).where(:deleted=>false).order(name: :desc)
    result = apply_filters(result, params)

    result = paginate(result)

    result = policy_scope(result)

    render(
      json: ActiveModel::ArraySerializer.new(
        result,
        each_serializer: Api::V1::UserSearchSerializer,
        root: 'users',
        meta: meta_attributes(result)
      )
    )
  end

  api! "lista todos los usuarios"
  param_group :paginate
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  example "Response" + '
{
  "users": [
    {
      "id": 19,
      "email": "zoie@yahoo.com",
      "fullname": "Zoie",
      "name": "Zoie"
    },
    {
      "id": 25,
      "email": "zackery@yahoo.com",
      "fullname": "Zackery",
      "name": "Zackery"
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 4,
    "total_count": 99
  }
}'
  def index
    users = User.where(:deleted=>false).order(name: :desc)
    users = apply_filters(users, params)

    users = paginate(users)

    users = policy_scope(users)

    render(
      json: ActiveModel::ArraySerializer.new(
        users,
        each_serializer: Api::V1::UserSearchSerializer,
        root: 'users',
        meta: meta_attributes(users)
      )
    )
  end

  api! "Muestra un usuario"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com",
       :url => "/api/v1/users/1"
  param :id, Fixnum, :desc => "User ID", :required => true
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  error 422, "API Error"
  example "Response" + '
{
  "user": {
    "id": 1,
    "email": "demo@gmail.com",
    "fullname": "Demo User",
    "name": "Demo User",
    "notification": true,
    "aliases": [],
    "folder_id": 1
  }
}'
  def show
    user = User.find(params[:id])
    return api_error(status: 422) if user.deleted?

    authorize user

    render(json: Api::V1::UserSerializer.new(user).to_json)
  end

  api! "Crea un usuario"
  param_group :create
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  error 422, "API Error"
  example "Response" + '
{
  "status": "ok",
  "message": "Please check your email to activate your account."
}
---------------
{
  "status": "fail",
  "message": "Email already exist"
}
---------------
{
  "errors": [
    {
      "email": [
        "Invalid format"
      ]
    },
    {
      "password_confirmation": [
        "doesn\'t match Password",
        "can\'t be blank"
      ]
    }
  ]
}
'
  def create
    user = User.find_by_email create_params[:email]
    
    return render(json: {:status=>"fail", :message=>t(:error_email_already_exist)}) unless user.nil?
    
    user = User.new(create_params)

    return api_error(status: 422, errors: user.errors) unless user.valid?

    user.save!
    user.send_activation_email

    render(
      json: {:status=>"ok", :message=>t(:message_activation_email)}
    )
  end

  api! "Actuliza un usuario"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  param_group :update
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  error 422, "API Error"
  def update
    user = User.find(params[:id])
    authorize user

    if !user.update_attributes(update_params)
      return api_error(status: 422, errors: user.errors)
    end

    render(
      json: Api::V1::UserSerializer.new(user).to_json,
      status: 200
    )
  end

  api!  "Eliminarse a si mismo"
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  param :id, Fixnum, :desc => "User ID", :required => true
  error 204, "Successfully deleted"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  error 422, "API Error - Error al intentar eliminar"
  error 422, "API Error - No existe el usuario"
  def destroy
    begin
      user = User.find(params[:id])
      authorize user

      if !user.delete_user
        return api_error(status: 422, errors: "Error al intentar eliminar")
      end

      head status: 204
    rescue => e
      return api_error(status: 422, errors: "No existe el usuario")
    end
  end

  private
    def create_params
      params.require(:user).permit(
        :email, :password, :password_confirmation
      ).delete_if{ |k,v| v.nil?}
    end
    def update_params
      params.require(:user).permit(
        :email, :password, :password_confirmation, :name,
        :lastname, :gender, :birthday, :occupation, :phone_number, 
        :country, :subregion, :alias_id, :notification, :deleted
      ).delete_if{ |k,v| v.nil?}
    end

end
