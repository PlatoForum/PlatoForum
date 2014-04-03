class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :require_user
  protect_from_forgery with: :exception

  helper_method :current_user, :pseudonym_gen

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_user
    if current_user
      return true
    end
    session[:return_to] ||= request.referer
    redirect_to signin_url
  end

  def sample(collection)
    while true 
      r = rand()
      adj = collection.find_by(:ran =>{"$lte" => r, "$gte" => r-0.01})
      puts adj
      break unless adj.nil?
    end
    return adj
  end

  def pseudonym_gen
    return sample(Town).name + sample(Adjective).word + sample(Name).word
  end
 

end
