class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_filter :require_user
  #protect_from_forgery with: :exception
  before_filter :check_user

  helper_method :current_user, :current_proxy, :pseudonym_gen

  private

  def check_user
    if session[:user_id]
      @user = User.find(session[:user_id])
    else
      
    end
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
    if !params[:id].nil?
      @topic = Comment.find(params[:id]).topic
    else
      @topic = Topic.find_by(:permalink => params[:permalink])
    end

    if @topic.nil?
      format.html { render text: "Error", status: 404 }
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

  def display_message(notification)
    if notification.noti_type == :NewComment 
      comment = Comment.find(notification.source_id) 
      return "#{comment.owner.display_name} 在 #{comment.topic.name} 中發佈了一則新評論 #{comment.display_abstract}" 
    elsif notification.noti_type == :NewSupport 
      comment = Comment.find(notification.source_id) 
      target = Comment.find(notification.destination_id) 
      return "#{comment.owner.display_name} 支援了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
    elsif notification.noti_type == :NewOppose 
      comment = Comment.find(notification.source_id) 
      target = Comment.find(notification.destination_id) 
      return "#{comment.owner.display_name} 反駁了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
    elsif notification.noti_type == :NewLike 
      someone = Proxy.find_by(:id => notification.source_id) 
      target = Comment.find(notification.destination_id) 
      return "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很讚！" 
    elsif notification.noti_type == :NewDislike 
      someone = Proxy.find_by(:id => notification.source_id) 
      target = Comment.find(notification.destination_id) 
      return "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很爛！" 
    end 
  end

  def display_link(notification)

  end

end
