# encoding: UTF-8
class AdminsController < ApplicationController
	before_filter :check_level, :except => [:de_robot]

	def check_level
		check_user
		if @user.level < 10
			redirect_to "/"
		end 
	end

	def admin
	end

	def robot
		session[:user_id_backup] = session.delete(:user_id)
		
		unless @user = User.find("aaaaaaaaaaaaaaaaaaaaaaaa")
			robot = User.new({:id => "aaaaaaaaaaaaaaaaaaaaaaaa"})
			robot.name = "潑辣機器人"
			robot.level = 4
			robot.omnitoken = "FAKE"
			robot.save
			@user = robot 
		end
		
		session[:user_id] = @user._id
		if request.post?
			redirect_to "/"
		else
			redirect_to request.referrer
		end
	end

	def de_robot
		#logger.error @user.id
		unless @user.is_robot?
			redirect_to "/" and return
		end
		session[:user_id] = session.delete(:user_id_backup)
		@user = User.find(session[:user_id])
		redirect_to "/" and return
	end

	def edit_user
		@target_user = User.find(params[:id])
	end

	# PATCH/PUT /admin/edit_user/users/1
	# PATCH/PUT /admin/edit_user/1.json
	def update_user
	@target_user = User.find(params[:id])
	respond_to do |format|
	  if @target_user.update(user_params)
	    format.html { redirect_to "/admin", notice: 'User was successfully updated.' }
	    format.json { head :no_content }
	  else
	    format.html { render action: 'edit' }
	    format.json { render json: @user.errors, status: :unprocessable_entity }
	  end
	end
	end

	# DELETE /admin/kill_user/1
	# DELETE /admin/kill_user/1.json
	def destroy_user
		@target_user = User.find(params[:id])
		@target_user.destroy
		respond_to do |format|
		  format.html { redirect_to "/admin" }
		  format.json { head :no_content }
		end
	end

	# POST /admin/broadcast/:message
	def broadcast
		User.all.each do |user|
      note = Notification.new
      note.noti_type = :Announcement
      note.source_id = "系統廣播：#{broadcast_params[:source_id]}"
      note.destination_id = broadcast_params[:destination_id]
      note.doc = Time.zone.now
      user.notifications << note
      note.save
      #note.push_notification
    end
    respond_to do |format|
	  	format.html { redirect_to request.referrer, notice: 'Broadcasted!' }
	    format.js { render 'broadcast'}
	  end
	end

	private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:level)
    end

    def broadcast_params
    	params.require(:broadcast).permit(:source_id, :destination_id)
    end
end
