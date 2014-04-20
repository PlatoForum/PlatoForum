# encoding: UTF-8
class FacebookController < ApplicationController
	def canvas
		redirect '/auth/failure' if request.params['error'] == 'access_denied'

	  settings.redirect_uri = 'https://apps.facebook.com/faceboku/'

	  url = request.params['code'] ? "/auth/facebook?signed_request=#{request.params['signed_request']}&state=canvas" : '/login'
	  redirect url
	end
end
