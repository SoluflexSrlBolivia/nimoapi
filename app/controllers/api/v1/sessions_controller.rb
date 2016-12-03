class Api::V1::SessionsController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:destroy]

  def_param_group :create do
    param :user, Hash, :required => true do
      param :email, String, :required => true
      param :password, String, :required => true
    end
  end

  api! "Login user"
  param_group :create
  error 401, 'Login sin exito'
  example "Response" + '
{
  "status": "ok",
  "session": {
    "id": 1,
    "email": "demo@gmail.com",
    "token": "WN+ztAi3m0xDZ4B+cc624UpOiyHJAHYdhK7PUtyVF4rdAGHBP2H/AStMeluO4b9U8pfodaqbhkapd4XOse0zrA==",
    "name": "Demo User"
  }
}
--------------------------
{
  "status": "fail",
  "message": "Account not activated. Check your email for the activation link."
}
'
  def create
    user = User.find_by(email: create_params[:email])
    if user && user.authenticate(create_params[:password])
      if user.activated?
        self.current_user = user
        render(
          json: {:status=>"ok", :session=>Api::V1::SessionSerializer.new(user, root: false)},
          status: 201
        )
      else
        render(
          json: {:status=>"fail", :message=>t(:account_not_active)},
          status: 201
        )
      end
    else
      return api_error(status: 401)
    end
  end

  def destroy
    self.current_user = nil
    head status: 204
  end

  private
  def create_params
    params.require(:user).permit(:email, :password)
  end
end
