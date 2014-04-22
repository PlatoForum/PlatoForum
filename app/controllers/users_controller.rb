# encoding: UTF-8
class UsersController < ApplicationController
  before_action :set_user
  # GET /users
  # GET /users.json
  helper_method :notification_message, :notification_url

  def index
    @users = User.all
  end

  def notification_message(noti)
    if noti.noti_type == :NewComment 
      comment = Comment.find(noti.source_id) 
      "#{comment.owner.display_name} 在 #{comment.topic.name} 中發佈了一則新評論 #{comment.display_abstract}" 
    elsif noti.noti_type == :NewSupport 
      comment = Comment.find(noti.source_id) 
      target = Comment.find(noti.destination_id) 
     "#{comment.owner.display_name} 支援了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
    elsif noti.noti_type == :NewOppose 
      comment = Comment.find(noti.source_id) 
      target = Comment.find(noti.destination_id) 
      "#{comment.owner.display_name} 反駁了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
    elsif noti.noti_type == :NewLike 
      someone = Proxy.find_by(:id => noti.source_id) 
      target = Comment.find(noti.destination_id) 
      "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很讚！" 
    elsif noti.noti_type == :NewDislike 
      someone = Proxy.find_by(:id => noti.source_id) 
      target = Comment.find(noti.destination_id) 
      "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很爛！"
    elsif noti.noti_type == :Other
      noti.source_id
    elsif noti.noti_type == :Announcement
      noti.source_id
    end
  end

  def notification_url(noti)
    comment = Comment.find(noti.source_id)  unless noti.source_id.nil?
    target = Comment.find(noti.destination_id) unless noti.destination_id.nil?

    case noti.noti_type 
          when :NewComment then "/#{comment.topic.permalink}/comment_#{comment.id}"  
          when :NewSupport then "/#{comment.topic.permalink}/comment_#{comment.id}"  
          when :NewOppose then "/#{comment.topic.permalink}/comment_#{comment.id}"  
          when :NewLike then "/#{target.topic.permalink}/comment_#{target.id}"
          when :NewDislike then "/#{target.topic.permalink}/comment_#{target.id}"
          when :Other then noti.destination_id
          when :Announcement then noti.destination_id
      end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /user/panel
  def panel
  end

  def toggle_show_FB
    @user.privacy_settings["show_FB"] = !@user.privacy_settings["show_FB"]
    #@user.allow_show_FB = !@user.allow_show_FB
    @user.save
  end

  def toggle_list_comments
    @user.privacy_settings["list_comments"] = !@user.privacy_settings["list_comments"]
    #@user.allow_list_comments = !@user.allow_list_comments
    @user.save
  end

  def toggle_noti
    @user.noti_settings[params[:type]] = !@user.noti_settings[params[:type]]
    @user.noti_settings["NewDislike"] = @user.noti_settings["NewLike"]
    @user.save
  end

  # GET /user/activities
  def activities
  end

  def achievements
  end

  def notification
    notification = @user.notifications.find(params[:id]) or not_found
    # if notification.noti_type == :NewComment 
    #   comment = Comment.find(notification.source_id)  
    #   noti_url = "/#{comment.topic.permalink}/comment_#{comment.id}"  
    # elsif notification.noti_type == :NewSupport  
    #   comment = Comment.find(notification.source_id)  
    #   noti_url = "/#{comment.topic.permalink}/comment_#{comment.id}" 
    # elsif notification.noti_type == :NewOppose  
    #   comment = Comment.find(notification.source_id)  
    #   noti_url = "/#{comment.topic.permalink}/comment_#{comment.id}" 
    # elsif notification.noti_type == :NewLike  
    #   target = Comment.find(notification.destination_id)  
    #   noti_url = "/#{target.topic.permalink}/comment_#{target.id}" 
    # elsif notification.noti_type == :NewDislike  
    #   target = Comment.find(notification.destination_id)  
    #   noti_url = "/#{target.topic.permalink}/comment_#{target.id}"
    # end  

    notification.read = true
    notification.save

    redirect_to notification_url(notification)
  end

  def notifications_more
    #logger.error params[:offset]
    @notifications = @user.notifications.sort!{|b,a| a.doc <=> b.doc}[ params[:offset].to_i , 5]
  end

  def notifications
    @user.notifications.each do |noti|
      case noti.noti_type
      when :NewComment then
        if Comment.find(noti.source_id).nil?
          noti.destroy
          next
        end
      when :NewSupport then
        if Comment.find(noti.source_id).nil?
          noti.destroy
          next
        end
      when :NewOppose then 
        if Comment.find(noti.source_id).nil?
          noti.destroy
          next
        end
      when :NewLike then
        if Comment.find(noti.destination_id).nil?
          noti.destroy
          next
        end
      when :NewDislike then
        if Comment.find(noti.destination_id).nil?
          noti.destroy
          next
        end
      end
    end
  end

  def noti_clear
    @user.notifications.each do |noti|
      noti.read = true
      noti.save
    end

    redirect_to "/user/notifications"
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # GET /:permalink/change_name
  def change_pseudonym
    unless session[:user_id].nil?
      @user = User.find_by(:id => session[:user_id])
      @target = Topic.find_by(:permalink => params[:permalink])
      @proxy = @user.proxies.find_by(:topic_id => @target._id)
      @proxy.update({:pseudonym => pseudonym_gen})
    end
    
    redirect_to "/#{params[:permalink]}"
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      check_user
      if @user.level == 0
        session[:return_to]=url_for(params)
        redirect_to "/signin"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :name, :level)
    end
end
