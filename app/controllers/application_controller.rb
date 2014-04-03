class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_filter :require_user
  #protect_from_forgery with: :exception

  helper_method :current_user, :current_proxy, :pseudonym_gen

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_proxy
    if current_user and session[:topic_id]
      if @current_proxy and @current_proxy.topic._id == session[:topic_id]
        return @current_proxy
      else
        @current_proxy = current_user.proxies.find_by(:topic_id => session[:topic_id]) 
      end
    end
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
    p = sample(Town).name + sample(Adjective).word + sample(Name).word
    while true
      if Proxy.find_by(:pseudonym => p).nil?
        return p
      end
      p = sample(Town).name + sample(Adjective).word + sample(Name).word
    end
  end
 

end
