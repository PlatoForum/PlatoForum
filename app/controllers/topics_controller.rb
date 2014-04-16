# encoding: UTF-8
class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :update, :destroy]
  before_action :before_show, only: [:show]

  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.all
  end

  def completelist
    @topics = Topic.all
  end

  def subscriptions
    if session[:user_id].nil?
      respond_to do |format|
        format.html { redirect_to "/", notice: "你必須先登入才能檢閱訂閱清單" }
      end
    end
    @user = User.find(session[:user_id])
    @topics = @user.subscriptions 
  end

  # GET /:permalink/comments
  # GET /:permalink/comments.json
  def show 
    @comments = @topic.comments
  end

  # GET /topics/new
  def new
    @topic = Topic.new
  end

  # GET /:permalink/subscribe
  def subscribe
    if session[:user_id].nil?
      respond_to do |format|
        format.html { redirect_to "/#{params[:permalink]}", notice: "你必須先登入才能訂閱議題" }
      end
    else
      @user = User.find_by(:id => session[:user_id])
      @topic = Topic.find_by(:permalink => params[:permalink])
      @user.subscriptions << @topic
      @user.save

      #redirect_to "/#{params[:permalink]}"
      respond_to do |format|
        format.html { redirect_to "/#{params[:permalink]}", notice: "訂閱議題『#{@topic.name}』"}
      end
    end
  end

  # GET /:permalink/subscribe
  def unsubscribe
    if session[:user_id].nil?
      respond_to do |format|
        format.html { redirect_to "/#{params[:permalink]}", notice: "你必須先登入才能訂閱議題" }
      end
    else
      @user = User.find_by(:id => session[:user_id])
      @topic = Topic.find_by(:permalink => params[:permalink])
      @user.subscriptions.delete(@topic)

      #redirect_to "/#{params[:permalink]}"
      respond_to do |format|
        format.html { redirect_to "/#{params[:permalink]}", notice: "取消訂閱議題『#{@topic.name}』"}
      end
    end
  end

  # GET /topics/1/edit
  def edit
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(topic_params)
    @topic.doc = Time.zone.now
    @topic.permalink = @topic.id if @topic.permalink.empty?

    if @topic.topic_type == :open #open topic
      @stance1 = Stance.new
      @stance1.number = 1
      #@stance1.description = "未分類"
      #@stance1.panel = "default"

      @stance1.save
      @topic.stances << @stance1

    else #yes/no topic
      @stance1 = Stance.new
      @stance1.number = 1
      @stance1.description = "支持"
      @stance1.panel = "success"

      # @stance2 = Stance.new
      # @stance2.number = 2
      # @stance2.description = "中立"
      # @stance2.panel = "warning"

      @stance3 = Stance.new
      @stance3.number = 3
      @stance3.description = "反對"
      @stance3.panel = "danger"

      @stance1.save
      # @stance2.save
      @stance3.save

      @topic.stances << @stance1
      # @topic.stances << @stance2
      @topic.stances << @stance3
    end

    respond_to do |format|
      if @topic.save
        format.html { redirect_to "/#{@topic.permalink}", notice: "創建新議題『#{@topic.name}』" }
        format.json { render action: 'show', status: :created, location: @topic }
      else
        format.html { render action: 'new', notice: @errormessage }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update
    if @topic.topic_type.nil?
      @topic.topic_type = :yesno
    end
    
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to "/#{@topic.permalink}", success: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to "/list" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      if params[:id].nil?
        @topic = Topic.find_by(:permalink => params[:permalink])
      else
        @topic = Topic.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topic_params
      params.require(:topic).permit(:name,:description,:permalink,:topic_type)
    end
end
