# encoding: UTF-8
class FacebookController < ApplicationController
	def canvas
		redirect_to '/auth/failure' if request.params['error'] == 'access_denied'

	  url = request.params['code'] ? "/auth/facebook?signed_request=#{request.params['signed_request']}&state=canvas" : '/signin'
	  redirect_to url
	end
end
