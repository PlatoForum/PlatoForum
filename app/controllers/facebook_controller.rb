# encoding: UTF-8
class FacebookController < ApplicationController
	layout "facebook"

  def fb_liked?
    session[:signed_request]['page']['liked'] if session[:signed_request]
  end
 
  def fb_admin?
    session[:signed_request]['page']['admin'] if session[:signed_request]
  end
 
  helper_method :fb_liked?, :fb_admin?
 
  before_filter do
    if params[:signed_request]
      oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'])
      session[:signed_request] = oauth.parse_signed_request(params[:signed_request])
    end
  end

	def canvas
	end

	def list
	end

	def bar
	end
end
