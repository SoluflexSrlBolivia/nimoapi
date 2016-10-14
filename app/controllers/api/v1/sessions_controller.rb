class Api::V1::SessionsController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:destroy]

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
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        render(
          json: {:status=>"fail", :message=>message},
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
