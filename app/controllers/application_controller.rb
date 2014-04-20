# encoding: UTF-8

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_filter :require_user
  #protect_from_forgery with: :exception
  #before_filter :check_first_visit
  before_filter :check_user
  after_filter :allow_iframe

  helper_method :check_user, :current_user, :current_proxy, :pseudonym_gen

  private

  def allow_iframe
    response.headers["X-Frame-Options"] = "GOFORIT"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def check_first_visit
    unless cookies[:visited] == "YES"
      redirect_to "/cover"
    end
    cookies[:visited] = { value: "YES" , expires: 1.year.from_now }
  end

  def check_user

    if session[:user_id]
      @user = User.find(session[:user_id])
    elsif cookies[:token] and cookie_user = User.find_by(:token => cookies[:token])
      @user = cookie_user
      session[:user_id] = @user.id
    end
    
    if @user and @user.omnitoken.nil? and !@user.is_robot?
      reset_session
      cookies.delete :token
    end

    unless @user
      unless anonymous_user = User.find_by(:level => 0)
        anonymous_user = User.new
        anonymous_user.level = 0
        anonymous_user.name = "路人"
        anonymous_user.save
      end
      @user = anonymous_user
    end

    return @user
  end

  def current_user
    @user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_proxy
    if current_user and session[:topic_id]
      if @current_proxy and @current_proxy.topic._id == session[:topic_id]
        return @current_proxy
      else
        @current_proxy = user.proxies.find_by(:topic_id => session[:topic_id]) 
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
    rand = Random.new
    while true
      r = rand.rand(1.0)
      word = collection.find_by(:ran =>{"$lte" => r, "$gte" => r-0.01})
      return word unless word.nil?
    end
  end

  def pseudonym_gen
    while true
      p = sample(Town).name + sample(Adjective).word + sample(Name).word

      puts "Created a new name: " + p

      if Proxy.find_by(:pseudonym => p).nil?
        return p
      end
    end
  end
 
  # This part for comment and stance
  def check_topic
    return if @topic
    if !params[:id].nil?
      @topic = Comment.find(params[:id]).topic
    else
      @topic = Topic.find_by(:permalink => params[:permalink]) || not_found
    end
  end

  def create_job(action, proxy_id, comment_id)
    job = Job.new
    job.action = action
    job.who = proxy_id
    job.post = comment_id
    job.save!
    redis = Redis.new
    redis.publish "jobqueue", job.to_json
  end

  def set_proxy #require login and proxy
    check_topic
    @user = User.find_by(:id => session[:user_id])
    @proxy = @user.proxies.find_by(:topic_id => @topic._id)
    return if @proxy
    @proxy = Proxy.new
    @proxy.topic = @topic
    @proxy.user = @user
    @proxy.pseudonym = pseudonym_gen
    @proxy.real_id = true if @user.id.to_s == "aaaaaaaaaaaaaaaaaaaaaaaa"
    @proxy.save!
  end

  def before_edit
    check_topic
    set_proxy
  end

  def before_show
    
    check_topic
    if session[:user_id].nil? #not logged in, use anonymous proxy
      @proxy = Proxy.new
      @proxy.topic = @topic
      @proxy.user = @user
      @proxy.pseudonym = "路人"
    else #logged in
      
      set_proxy
    end
  end

end
