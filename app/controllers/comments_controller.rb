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
    @target = Topic.find_by(:permalink => params[:permalink])
    if @target.nil?()
      format.html { render text: "Error", status: 404 }
    else
      @comments = @target.comments
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
    @comment.target = @target
    
    # @comment.stance = params[:comment][:stance].to_i

    # if @comment.stance > 1
    #   @comment.stance = 1
    # end 
      
    # if @comment.stance < -1
    #   @comment.stance = -1
    # else
    
    @comment.owner = @proxy
    
    respond_to do |format|
      if @comment.save
        format.html { redirect_to "/#{params[:permalink]}/comments", notice: '已成功發表評論！' }
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
        format.html { redirect_to "/#{@comment.target.permalink}/comments", notice: 'Comment was successfully updated.' }
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
    @permalink = @comment.target.permalink
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to "/#{@permalink}/comments" }
      format.json { head :no_content }
    end
  end

  # LIKE/NERUTRAL/DISLIKE /comments/1/(ACTION)
  # def like
  #   c = Comment.find_by(:id => params[:id])
  #   c.likes << @proxy
  #   c.save
  #   create_job(:like, @proxy._id, c._id) 
  #   create_job(:undislike, @proxy._id, c._id) if @proxy.disapprovals.delete(c)
  #   respond_to do |format|
  #     format.html { redirect_to "/#{c.target.permalink}/comments", notice: '已成功表達支持' }
  #   end
  # end

  # def neutral
  #   c = Comment.find_by(:id => params[:id])
  #   create_job(:unlike, @proxy._id, c._id) if @proxy.approvals.delete(c) 
  #   create_job(:undislike, @proxy._id, c._id) if @proxy.disapprovals.delete(c)
  #   respond_to do |format|
  #     format.html { redirect_to "/#{c.target.permalink}/comments", notice: '已成功表達中立' }
  #   end
  # end

  # def dislike
  #   c = Comment.find_by(:id => params[:id])
  #   c.dislikes << @proxy
  #   c.save
  #   create_job(:dislike, @proxy._id, c._id)
  #   create_job(:unlike, @proxy._id, c._id) if @proxy.approvals.delete(c) 
  #  respond_to do |format|
  #    format.html { redirect_to "/#{c.target.permalink}/comments", notice: '已成功表達反對' }
  #  end
  #end


  # LIKE/NERUTRAL/DISLIKE /comments/1/(ACTION)
  def like
      c = Comment.find_by(:id => params[:id])
      @proxy.disapprovals.delete(c)
      c.likes << @proxy
      c.save
      
      redirect_to "/comments/#{c.id}"
      # respond_to do |format|
      #   format.html { redirect_to "/comments/#{c.id}", notice: "你覺得『#{c.subject}』讚！" }
      # end
  end

  def neutral
      c = Comment.find_by(:id => params[:id])
      @proxy.approvals.delete(c) 
      @proxy.disapprovals.delete(c) 

      redirect_to "/comments/#{c.id}"
      # respond_to do |format|
      #   format.html { redirect_to "/comments/#{c.id}", notice: "你對『#{c.subject}』沒有感覺" }
      # end
  end

  def dislike
      c = Comment.find_by(:id => params[:id])
      @proxy.approvals.delete(c) 
      c.dislikes << @proxy
      c.save

      redirect_to "/comments/#{c.id}"
      # respond_to do |format|
      #   format.html { redirect_to "/comments/#{c.id}", notice: "你覺得『#{c.subject}』爛！" }
      # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])

      @stance = Stance.new

      @stance.number = @comment.stance
      if @stance.number == 1
        @stance.description = "支持"
      end
      if @stance.number == 2
        @stance.description = "中立"
      end
      if @stance.number == 3
        @stance.description = "反對"
      end
      @stance.target = @comment.target

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:subject, :body, :stance)
    end

end
