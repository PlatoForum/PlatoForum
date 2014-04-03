class SessionsController < ApplicationController
  skip_before_action :require_user, only: [:new, :create]

  def new
  end
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid']).first || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    #redirect_to session.delete(:return_to) || root_path
    #redirect_to params[:lastpage]
  end

  def destroy
    reset_session
    #session.delete(:user_id)
    #redirect_to root_url
  end
end
