class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :activities, :notifications, :notification]
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  def notification_message(notification)
    if notification.noti_type == :NewComment 
      comment = Comment.find(notification.source_id) 
      "#{comment.owner.display_name} 在 #{comment.topic.name} 中發佈了一則新評論 #{comment.display_abstract}" 
    elsif notification.noti_type == :NewSupport 
      comment = Comment.find(notification.source_id) 
      target = Comment.find(notification.destination_id) 
     "#{comment.owner.display_name} 支援了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
    elsif notification.noti_type == :NewOppose 
      comment = Comment.find(notification.source_id) 
      target = Comment.find(notification.destination_id) 
      "#{comment.owner.display_name} 反駁了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
    elsif notification.noti_type == :NewLike 
      someone = Proxy.find_by(:id => notification.source_id) 
      target = Comment.find(notification.destination_id) 
      "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很讚！" 
    elsif notification.noti_type == :NewDislike 
      someone = Proxy.find_by(:id => notification.source_id) 
      target = Comment.find(notification.destination_id) 
      "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很爛！"
    elsif notification.noti_type == :Other
      notification.source_id
    end
  end

  def notification_url(notification)
    comment = Comment.find(notification.source_id)  unless notification.source_id.nil?
    target = Comment.find(notification.destination_id) unless notification.destination_id.nil?

    case notification.noti_type 
          when :NewComment then "/#{comment.topic.permalink}/comment_#{comment.id}"  
          when :NewSupport then "/#{comment.topic.permalink}/comment_#{comment.id}"  
          when :NewOppose then "/#{comment.topic.permalink}/comment_#{comment.id}"  
          when :NewLike then "/#{target.topic.permalink}/comment_#{target.id}"
          when :NewDislike then "/#{target.topic.permalink}/comment_#{target.id}"
          when :Other then notification.destination_id
      end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /user/panel
  def panel
  end

  # GET /user/activities
  def activities
  end

  def achievements
  end

  def notification
    notification = Notification.find(params[:id])
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

  def notifications
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

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if session[:user_id].nil?
        redirect_to "/signin"
      else
        @user = User.find(session[:user_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :name)
    end
end
