# encoding: UTF-8
class CommentsController < ApplicationController
  include ActionView::Helpers::TextHelper
  #require login to view comments
  #after_filter :require_user
  #protect_from_forgery with: :exception
  
  #before_action :check_topic
  before_action :set_comment, only: [:show, :show_reply, :edit, :update, :destroy, :new_update]
  before_action :before_edit, only: [:new, :create, :reply, :like, :neutral, :dislike, :reply, :reply_old, :new_update]
  before_action :before_show, only: [:index, :show, :show_more, :show_reply]

  # GET /:permalink/comments
  # GET /:permalink/comments.json
  # MOVED TO TOPICS#SHOW
  def index
    @topic = Topic.find_by(:permalink => params[:permalink]) || not_found
    @comments = @topic.comments
  end

  # GET /:permalink/comments/more_stance_:stance/:offset
  def show_more
    @stance = @topic.stances.find(params[:stance])
    #@comments = @stance.comments.sort!{|b,a| a.importance_factor <=> b.importance_factor}[ params[:offset].to_i , 5]
    if params[:sort] == "doc"
      @comments = @stance.comments.sort!{|b,a| a.doc <=> b.doc}[ params[:offset].to_i , 5]
    else
      @comments = @stance.comments[ params[:offset].to_i , 5]
    end
  end

  # GET /link_comment_:id
  # GET /comments/1.json
  # def show_link
  #   unless session[:user_id].nil?
  #     @proxy.read_comments << Comment.find(params[:id])
  #     @proxy.save
  #   end
  #   respond_to do |format|
  #     format.html
  #     format.js
  #   end
  # end

  # GET /:permalink/comment_:id
  # GET /comment_:id
  def show
    unless session[:user_id].nil?
      @proxy.read_comments << Comment.find(params[:id])
      @proxy.save
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show_reply
  end

  # GET /:permalink/comments/new
  def new
    @comment = Comment.new
    @comment.owner = @proxy
    @target = @topic.comments.find(params[:target]) unless params[:target].nil?
    @opinion = params[:opinion] unless params[:opinion].nil?
  end
  
  def set_reply_relations
    @target = Comment.find(params[:id])
    if params[:comment][:opinion] == "support"
      @target.supported << @comment
      action = :support
    else #oppose
      @target.opposed << @comment
      action = :oppose
    end
    #@target.update_importance_factor
    @target.save
    create_job(action, @target._id, @comment._id)
  end

  def new_update
    if @user != @comment.owner.user
      redirect_to request.referrer or "/"
    end

    @update = Update.new
    @update.content = params[:update][:content]
    @update.doc = Time.zone.now
    @comment.updates << @update
    @update.save

    respond_to do |format|
      format.html
      format.js 
    end
  end

  # POST /:permalink/comment_:id/reply_old
  def reply_old
    
    @target = Comment.find(params[:id])
    @comment = Comment.find(comment_params[:old_id])

    set_reply_relations
    notify_new_reply

    respond_to do |format|
      format.html { redirect_to "/#{@topic.permalink}/comment_#{@target.id}", notice: '已成功回應評論！' }
      format.json { render action: 'show', status: :created, location: @comment }
    end
  end

  # POST /:permalink/comment_:id/reply
  def reply
    @comment = Comment.new(comment_params)
    @comment.topic = @topic
    @comment.doc = Time.zone.now
    @comment.owner = @proxy
    @proxy.read_comments << @comment

    @target = Comment.find(params[:id])

    @stance = @topic.stances.find(params[:comment][:stance])
    @comment.stance = @stance

    respond_to do |format|
      if @comment.save

        notify_new_comment
        notify_new_reply

        @stance.comments << @comment

        set_reply_relations

        format.html { redirect_to "/#{@topic.permalink}/comment_#{@target.id}", notice: '已成功回應評論！' }
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
    @proxy.read_comments << @comment

    @stance = @topic.stances.find(comment_params[:stance])
    @comment.stance = @stance
    
    respond_to do |format|
      if @comment.save
        notify_new_comment
        @stance.comments << @comment
        format.html { redirect_to "/#{@comment.topic.permalink}", notice: '已成功發表評論！' }
        format.js { render 'create_success' }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { render action: 'new', notice: @errormessage }
        format.js { render 'create_failed' }
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

  # DELETE /:permalink/comment_:id
  def destroy
    unless @user.level >= 8
      redirect_to "/#{params[:permalink]}/comment_#{params[:id]}" and return
    end
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to "/#{params[:permalink]}" }
      format.json { head :no_content }
    end
  end

  # LIKE/NERUTRAL/DISLIKE /comments/1/(ACTION)
  def like
      @c = Comment.find_by(:id => params[:id])
      @c.likes << @proxy
      #@c.update_importance_factor
      @c.save
      create_job(:like, @proxy._id, @c._id) 
      create_job(:undislike, @proxy._id, @c._id) if @proxy.disapprovals.delete(@c)
      # redirect_to "/comments/#{@c.id}"
      cancel_new_dislike
      notify_new_like
      @action = "like"
      respond_to do |format|
        #format.html { redirect_to request.referrer, notice: "你覺得『#{@c.subject}』讚！" }
        format.js { render 'opinions'}
        format.json { head :no_content }
      end
  end

  def neutral
      @c = Comment.find_by(:id => params[:id])
      create_job(:unlike, @proxy._id, @c._id) if @proxy.approvals.delete(@c) 
      create_job(:undislike, @proxy._id, @c._id) if @proxy.disapprovals.delete(@c)
      # redirect_to "/comments/#{c.id}"
      #@c.update_importance_factor
      @c.save
      cancel_new_dislike
      cancel_new_like
      @action = "neutral"
      respond_to do |format|
        #format.html { redirect_to request.referrer, notice: "你對『#{@c.subject}』沒有感覺" }
        format.js {render 'opinions'}
        format.json { head :no_content }
      end
  end

  def dislike
      @c = Comment.find_by(:id => params[:id])
      @c.dislikes << @proxy
      #@c.update_importance_factor
      @c.save
      create_job(:dislike, @proxy._id, @c._id)
      create_job(:unlike, @proxy._id, @c._id) if @proxy.approvals.delete(@c) 
      # redirect_to "/comments/#{@c.id}"
      cancel_new_like
      notify_new_dislike
      @action = "dislike"
      respond_to do |format|
        #format.html { redirect_to request.referrer, notice: "你覺得『#{@c.subject}』爛！" }
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

        subscriber.notifications << note
        note.save
        #note.push_notification
      end
    end
  end

  def notify_new_reply
    unless @target.owner.user == @user
      note = Notification.new
      if params[:comment][:opinion] == "support"
        note.noti_type = :NewSupport
      else #oppose
        note.noti_type = :NewOppose
      end
      note.source_id = @comment.id
      note.destination_id = @target.id
      note.doc = Time.zone.now
      @target.owner.user.notifications << note
      note.save
      #note.push_notification
    end
  end

  def cancel_new_like
    criteria = {noti_type: :NewLike, source_id: @proxy.id, destination_id: @c.id}
    @c.owner.user.notifications.where(criteria).destroy()
  end

  def cancel_new_dislike
    criteria = {noti_type: :NewDislike, source_id: @proxy.id, destination_id: @c.id}
    @c.owner.user.notifications.where(criteria).destroy()
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
      #note.push_notification
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
      #note.push_notification
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
      params.require(:comment).permit(:subject, :body, :stance, :old_id, :tag, :tag_url)
    end

    def update_params
      params.require(:update).permit(:content)
    end

    def create_job(action, proxy_id, comment_id)
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
