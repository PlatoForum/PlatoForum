class CommentsController < ApplicationController
  
  #require login to view comments
  #after_filter :require_user
  #protect_from_forgery with: :exception
  
  #before_action :check_topic
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :before_edit, only: [:new, :create, :like, :neutral, :dislike]
  before_action :before_show, only: [:index, :show]

  # GET /:permalink/comments
  # GET /:permalink/comments.json
  def index
    @topic = Topic.find_by(:permalink => params[:permalink])
    if @topic.nil?()
      format.html { render text: "Error", status: 404 }
    else
      @comments = @topic.comments
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /:permalink/comments/new
  def new
    @comment = Comment.new
    @comment.owner = @proxy
  end

  # GET /comments/1/edit
  #def edit
  #end

  # POST /:permalink/comments
  # POST /:permalink/comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.topic = @topic
    @comment.doc = Time.zone.now
    
    # @comment.stance = params[:comment][:stance].to_i

    # if @comment.stance > 1
    #   @comment.stance = 1
    # end 
      
    # if @comment.stance < -1
    #   @comment.stance = -1
    # else
    
    @comment.owner = @proxy
    @comment.stance = @topic.stances.find_by(:number => comment_params[:stance])
    
    respond_to do |format|
      if @comment.save

        @stance = @topic.stances.find_by(:number => comment_params[:stance])
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
      c = Comment.find_by(:id => params[:id])
      c.likes << @proxy
      c.save
      create_job(:like, @proxy._id, c._id) 
      create_job(:undislike, @proxy._id, c._id) if @proxy.disapprovals.delete(c)
      # redirect_to "/comments/#{c.id}"
      respond_to do |format|
        format.html { redirect_to "/comments/#{c.id}", notice: "你覺得『#{c.subject}』讚！" }
      end
  end

  def neutral
      c = Comment.find_by(:id => params[:id])
      create_job(:unlike, @proxy._id, c._id) if @proxy.approvals.delete(c) 
      create_job(:undislike, @proxy._id, c._id) if @proxy.disapprovals.delete(c)
      # redirect_to "/comments/#{c.id}"
      respond_to do |format|
        format.html { redirect_to "/comments/#{c.id}", notice: "你對『#{c.subject}』沒有感覺" }
      end
  end

  def dislike
      c = Comment.find_by(:id => params[:id])
      c.dislikes << @proxy
      c.save
      create_job(:dislike, @proxy._id, c._id)
      create_job(:unlike, @proxy._id, c._id) if @proxy.approvals.delete(c) 
      # redirect_to "/comments/#{c.id}"
      respond_to do |format|
        format.html { redirect_to "/comments/#{c.id}", notice: "你覺得『#{c.subject}』爛！" }
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
      job = Job.new
      job.action = action
      job.group = @topic._id
      job.who = proxy_id
      job.post = comment_id
      REDIS.publish "jobqueue", job.to_json
    end
end
