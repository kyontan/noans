load 'routes_user-activity_register.rb'
load 'routes_user-activity_logging.rb'

get '/my/?' do
	haml :mypage, locals: {path: "mypage"}
end