class AuthController < ApplicationController
  include SessionsHelper
  def gettoken
    token = get_token_from_code params[:code]
    session[:azure_token] = token.to_hash
    session[:user_mail] = get_user_email token.token
    user_info token.token
    @user = User.find_by(email: session[:user_mail])
    if @user.nil?
      # var_new = User.new(:name => session[:user_mail], :email => session[:user_mail], :professor => true, :activated => true, :admin => false)
      var_new = user_info token.token
      if var_new.save
        log_in var_new
        redirect_to var_new
      else
        flash[:errors] = "No se pudo guardar el usuario en la base de datos."
      end
    else
      log_in @user
      redirect_to @user
    end

    # render text: "SAVED in session cookie."
  end
end
