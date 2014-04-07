class SessionsController < ApplicationController
  skip_before_action :require_user, only: [:create]

  def new
    session[:return_to] = request.referrer if session[:return_to].nil?
    
    logger.info "Called by "+ session[:return_to]

    redirect_to "/auth/facebook"
  end
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid']).first || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    
    redirect_to session.delete(:return_to)
    #redirect_to params[:lastpage]
  end

  def destroy
    #@return_to = session[:return_to]
    reset_session
    #session[:return_to] = @return_to
    #logger.info "Called by "+ request.referrer
    #session.delete(:user_id)
    redirect_to root_url
  end
end
