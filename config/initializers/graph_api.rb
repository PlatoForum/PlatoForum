GRAPH_API = Koala::Facebook::API.new(Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET']).get_app_access_token)
