class SessionsController < ApplicationController
  skip_before_action :require_user, only: [:create, :new]

  def new
    session[:return_to] = request.referrer if session[:return_to].nil?
    if session[:return_to].match(/\/cover$/)
      session[:return_to] = "/"
    end

    if session[:user_id]
      redirect_to session.delete(:return_to)
    else
      redirect_to "/auth/facebook"
    end
  end
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid']).first || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    user.level = 2
    user.save
    
    cookies.permanent[:token] = user.token

    redirect_to session.delete(:return_to)
    #redirect_to params[:lastpage]
  end

  def destroy
    #@return_to = session[:return_to]
    reset_session
    cookies.delete :token
    #session[:return_to] = @return_to
    #logger.info "Called by "+ request.referrer
    #session.delete(:user_id)
    redirect_to root_url
  end
end
