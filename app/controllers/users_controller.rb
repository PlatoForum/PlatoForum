class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :activities, :notifications]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
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

  def notification
    notification = Notification.find(params[:id])
    if notification.noti_type == :NewComment 
      comment = Comment.find(notification.source_id)  
      noti_url = "/#{comment.topic.permalink}/comment_#{comment.id}"  
    elsif notification.noti_type == :NewSupport  
      comment = Comment.find(notification.source_id)  
      noti_url = "/#{comment.topic.permalink}/comment_#{comment.id}" 
    elsif notification.noti_type == :NewOppose  
      comment = Comment.find(notification.source_id)  
      noti_url = "/#{comment.topic.permalink}/comment_#{comment.id}" 
    elsif notification.noti_type == :NewLike  
      target = Comment.find(notification.destination_id)  
      noti_url = "/#{target.topic.permalink}/comment_#{target.id}" 
    elsif notification.noti_type == :NewDislike  
      target = Comment.find(notification.destination_id)  
      noti_url = "/#{target.topic.permalink}/comment_#{target.id}" 
    end  

    notification.read = true
    notification.save
    
    redirect_to noti_url
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
