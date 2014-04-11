class AdminsController < ApplicationController
	before_filter :check_level
	def check_level
		check_user
		logger.error check_user.level + "!!!!!!"
		#if @user.level < 10
		#	redirect_to "/"
		#end 
	end

	def admin
	end
end
