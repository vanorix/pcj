class AuthController < ApplicationController
  def gettoken
    token = get_token_from_code params[:code]
    session[:azure_token] = token.to_hash
    session[:user_mail] = get_user_email token.token
    render text: "Email: #{email}, TOKEN: #{token.token}. SAVED in session cookie."
  end
end
