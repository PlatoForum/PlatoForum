class StancesController < ApplicationController
  before_action :set_stance, only: [:show, :edit, :update, :destroy, :show_more_importance, :show_more_time]
  
  before_action :before_edit, only: [:new, :create, :like, :neutral, :dislike]
  before_action :before_show, only: [:index, :show, :show_more_importance, :show_more_time]

  # GET /stances
  # GET /stances.json
  def index
    @stances = Stance.all
  end

  # GET /stances/1
  # GET /stances/1.json
  # GET /:permalink/:stance
  def show
  end

  def show_more_importance
    @comments = @stance.comments.sort!{|b,a| a.importance_factor <=> b.importance_factor}[ params[:offset].to_i , 5]
  end

  def show_more_time
    @comments = @stance.comments.sort!{|b,a| a.doc <=> b.doc}[ params[:offset].to_i , 5]
  end

  # GET /stances/new
  def new
    @stance = Stance.new
  end

  # GET /stances/1/edit
  def edit
  end

  # POST /stances
  # POST /stances.json
  def create
    @stance = Stance.new(stance_params)

    respond_to do |format|
      if @stance.save
        format.html { redirect_to @stance, notice: 'Stance was successfully created.' }
        format.json { render action: 'show', status: :created, location: @stance }
      else
        format.html { render action: 'new' }
        format.json { render json: @stance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stances/1
  # PATCH/PUT /stances/1.json
  def update
    respond_to do |format|
      if @stance.update(stance_params)
        format.html { redirect_to @stance, notice: 'Stance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stances/1
  # DELETE /stances/1.json
  def destroy
    @stance.destroy
    respond_to do |format|
      format.html { redirect_to stances_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stance
      @topic = Topic.find_by(:permalink => params[:permalink])
      #@stance = Stance.find(params[:id]) # use integer for now
      @stance = @topic.stances.find_by(:number => params[:stance].to_i)

      unless session[:user_id].nil?
        @user = User.find(session[:user_id])
      end

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stance_params
      params[:stance]
    end
end
