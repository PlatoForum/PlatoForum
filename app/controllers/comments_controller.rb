class CommentsController < ApplicationController
  
  #require login to view comments
  #after_filter :require_user
  #protect_from_forgery with: :exception
  
  #before_action :check_topic
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :before_edit, only: [:new, :create, :reply, :like, :neutral, :dislike]
  before_action :before_show, only: [:index, :show]

  # GET /:permalink/comments
  # GET /:permalink/comments.json
  def index
    @topic = Topic.find_by(:permalink => params[:permalink]) || not_found
    @comments = @topic.comments
  end

  # GET /:permalink/comment_:id
  # GET /comments/1.json
  def show
    unless session[:user_id].nil?
      @user.read_comments << Comment.find(params[:id])
      @user.save
    end
  end

  # GET /:permalink/comments/new
  def new
    @comment = Comment.new
    @comment.owner = @proxy
  end
  
  def set_reply_relations
    @target = Comment.find(params[:id])
    if comment_params[:stance] == "support"
      @target.supported << @comment
    else #oppose
      @target.opposed << @comment
    end
    @target.save
  end

  # POST /:permalink/comment_:id/reply
  def reply
    @comment = Comment.new(comment_params)
    @comment.topic = @topic
    @comment.doc = Time.zone.now
    @comment.owner = @proxy

    @target = Comment.find(params[:id])

    if @topic.topic_type == :yesno
      if comment_params[:stance] == "support"
        @stance = @target.stance
        action = :support
      else #oppose
        @stance_number = 4 - @target.stance.number
        @stance = @topic.stances.find_by(:number => @stance_number)
        action = :oppose
      end
      @comment.stance = @stance
    else
      @stance = @topic.stances.sort!{|b,a| a.comments.where(:owner => @proxy).count <=> b.comments.where(:owner => @proxy).count }.first
      @comment.stance = @stance
    end
    
    create_job(action, @target._id, @comment._id)
    respond_to do |format|
      if @comment.save

        notify_new_comment
        notify_new_reply

        @stance.comments << @comment

        set_reply_relations

        format.html { redirect_to "/#{params[:permalink]}/comment_#{@target.id}", notice: '已成功發表評論！' }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { render action: 'new', notice: @errormessage }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /:permalink/comments
  # POST /:permalink/comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.topic = @topic
    @comment.doc = Time.zone.now
    
    @comment.owner = @proxy

    if @topic.topic_type == :yesno
      @stance = @topic.stances.find_by(:number => comment_params[:stance])
      @comment.stance = @stance
    else
      @stance = @topic.stances.sort!{|b,a| a.comments.where(:owner => @proxy).count <=> b.comments.where(:owner => @proxy).count }.first
      @comment.stance = @stance
    end
    
    respond_to do |format|
      if @comment.save
        notify_new_comment
        @stance.comments << @comment
        format.html { redirect_to "/#{params[:permalink]}", notice: '已成功發表評論！' }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { render action: 'new', notice: @errormessage }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to "/#{@comment.topic.permalink}", notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @permalink = @comment.topic.permalink
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to "/#{@permalink}" }
      format.json { head :no_content }
    end
  end

  # LIKE/NERUTRAL/DISLIKE /comments/1/(ACTION)
  def like
      @c = Comment.find_by(:id => params[:id])
      @c.likes << @proxy
      @c.save
      create_job(:like, @proxy._id, @c._id) 
      create_job(:undislike, @proxy._id, @c._id) if @proxy.disapprovals.delete(@c)
      # redirect_to "/comments/#{@c.id}"
      notify_new_like
      @action = "like"
      respond_to do |format|
        format.html { redirect_to request.referrer, notice: "你覺得『#{@c.subject}』讚！" }
        format.js { render 'opinions'}
        format.json { head :no_content }
      end
  end

  def neutral
      @c = Comment.find_by(:id => params[:id])
      create_job(:unlike, @proxy._id, @c._id) if @proxy.approvals.delete(@c) 
      create_job(:undislike, @proxy._id, @c._id) if @proxy.disapprovals.delete(@c)
      # redirect_to "/comments/#{c.id}"
      @action = "neutral"
      respond_to do |format|
        format.html { redirect_to request.referrer, notice: "你對『#{c.subject}』沒有感覺" }
        format.js {render 'opinions'}
        format.json { head :no_content }
      end
  end

  def dislike
      @c = Comment.find_by(:id => params[:id])
      @c.dislikes << @proxy
      @c.save
      create_job(:dislike, @proxy._id, @c._id)
      create_job(:unlike, @proxy._id, @c._id) if @proxy.approvals.delete(@c) 
      # redirect_to "/comments/#{@c.id}"
      notify_new_dislike
      @action = "dislike"
      respond_to do |format|
        format.html { redirect_to request.referrer, notice: "你覺得『#{@c.subject}』爛！" }
        format.js {render 'opinions'}
        format.json { head :no_content }
      end
  end

  def notify_new_comment
    @topic.subscribed_by.each do |subscriber|
      unless subscriber == @user
        note = Notification.new
        note.noti_type = :NewComment
        note.source_id = @comment.id
        note.doc = Time.zone.now
        subscriber.notifications << note
        note.save 
      end
    end
    @user.read_comments << @comment
  end

  def notify_new_reply
    unless @target.owner.user == @user
      note = Notification.new
      if comment_params[:stance] == "support"
        note.noti_type = :NewSupport
      else #oppose
        note.noti_type = :NewOppose
      end
      note.source_id = @comment.id
      note.destination_id = @target.id
      note.doc = Time.zone.now
      @target.owner.user.notifications << note
      note.save 
    end
  end

  def notify_new_like
    unless @c.owner.user == @user
      note = Notification.new
      note.noti_type = :NewLike
      note.source_id = @proxy.id
      note.destination_id = @c.id
      note.doc = Time.zone.now
      @c.owner.user.notifications << note
      note.save 
    end
  end

  def notify_new_dislike
    unless @c.owner.user == @user    
      note = Notification.new
      note.noti_type = :NewDislike
      note.source_id = @proxy.id
      note.destination_id = @c.id
      note.doc = Time.zone.now
      @c.owner.user.notifications << note
      note.save 
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
      @stance = @comment.stance
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:subject, :body, :stance)
    end

    def create_job(action, proxy_id, comment_id)
      if @topic.topic_type == :yesno
        return true
      end
      job = Job.new
      job.action = action
      job.group = @topic._id
      if action == :support || action == :oppose
        job.target = proxy_id
      else
        job.who = proxy_id
      end
      job.post = comment_id
      REDIS.publish "jobqueue", job.to_json
      return true
    end
end
