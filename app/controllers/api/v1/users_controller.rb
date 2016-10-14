class Api::V1::UsersController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:show, :update, :destroy, :picture]
  
  def search 
    result = User.search(params[:q]).where(:deleted=>false).order(firstname: :desc)
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
  
  def index
    users = User.where(:deleted=>false).order(firstname: :desc)
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

  def show
    user = User.find(params[:id])
    return api_error(status: 422) if user.deleted?

    authorize user

    render(json: Api::V1::UserSerializer.new(user).to_json)
  end

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

  def destroy
    user = User.find(params[:id])
    authorize user

    if !user.delete_user
      return api_error(status: 500)
    end

    head status: 204
  end

  private
    def create_params
      params.require(:user).permit(
        :email, :password, :password_confirmation
      ).delete_if{ |k,v| v.nil?}
    end
    def update_params
      params.require(:user).permit(
        :email, :password, :password_confirmation, :firstname, 
        :lastname, :gender, :birthday, :occupation, :phone_number, 
        :country, :subregion, :alias_id, :notification, :deleted
      ).delete_if{ |k,v| v.nil?}
    end
end
