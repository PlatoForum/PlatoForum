class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :update, :destroy]

  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.all
  end

  # GET /topics/1
  # GET /topics/1.json
  # This is no longer used
  def show 
    #session[:topic_id] = params[:id]
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

    respond_to do |format|
      if @topic.save
        format.html { redirect_to "/#{@topic.permalink}/comments", notice: "創建新議題『#{@topic.name}』" }
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
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to "/#{@topic.permalink}/comments", success: 'Topic was successfully updated.' }
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
      format.html { redirect_to topics_url }
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
      params.require(:topic).permit(:name,:description,:permalink)
    end
end
