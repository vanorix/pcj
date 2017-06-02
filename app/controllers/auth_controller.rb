class AuthController < ApplicationController
  include SessionsHelper
  def gettoken
    token                 = get_token_from_code params[:code]
    session[:azure_token] = token.to_hash
    session[:user_mail]   = get_user_email token.token

    aux = User.find_by( name: session[:user_mail])
    if aux == nil
        usuario = User.new(:name => session[:user_mail], :email => session[:user_mail], :professor => true, :activated => true, :admin => false)
        usuario.save
        log_in aux
        redirect_to aux
    else
        log_in aux
        redirect_to aux

    end
    #render text: "SAVED in session cookie."
    # TODO:
    # 	buscar si el correo esta en la base de datos
    # 		- si esta da permiso y redirecionar
    # 		- si no esta agragar a la base datos y redirecionar
    # 	redirecionar a "dashboard"
    # => poder hacer log_out
  end
end
