class Api::V1::PasswordResetsController < Api::V1::BaseController
	#before_filter :authenticate_user!

  api! "Reset password"
	def create
    user = User.find_by(email: user_params[:email].downcase)
    if user
      user.create_reset_digest
      user.send_password_reset_email
      render(
        json: {:status=>"ok", :message=>t(:email_instruction_change_password)},
        status: 201
      )
    else
      render(
        json: {:status=>"fail", :message=>t(:email_not_found)},
        status: 201
      )
    end
  end

	private
    def user_params
      params.require(:user).permit(:email)
    end
end