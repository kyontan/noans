# Coding:UTF-8

before '/test*' do
	require_login(true)
end

get '/test/?' do
	haml :test, locals: {common_css: true, mode: "get"}
end

post '/test/?' do
	haml :test, locals: {common_css: true, mode: "post", params: params}
end

get '/test/raise/?' do
	raise "Raise for debugging"
end

get '/test/error/:error_status/?' do
	halt params[:error_status].to_i
end

get %r(/test/([0-9]{3})/?) do
	status = params[:captures].first.to_i
	halt status
end

get '/test/render/:obj/?' do
	haml params[:obj].to_sym, layout: false,
				locals: {
			 		path: params[:obj],
			 		params: Hash::new(""),
			 		title: "Test render - #{params[:obj]}"
			 	}
end

get '/test/user_data/:spec/?' do
	eval "user_data.#{params[:spec]}"
end

get '/test/session/get/?' do
	session[:test]
end

get '/test/session/set/?' do
	session[:test] = "Sessioned! #{Time.now}"
	redirect_to "/session/get"
end

get '/test/session/clear/?' do
	session[:test] = nil
end

get '/test/post/?' do
	"Post"
end

get '/test/reset/?' do
	require_login(true)

	system("touch ./tmp/restart.txt")

	#halt 500 unless $CHILD_STATUS.exitstatus.zero?
	# if request.referer == ?/
	# 	redirect_to ?/
	# else
	# 	redirect request.referer
	# end
	redirect back
	# "#{$CHILD_STATUS.exitstatus} <a href='#{link_to ?/}'>back to top</a>"
end

#set :inline_template :true
before '/test/md/' do
	require 'rdiscount'
end

get '/test/md/:obj/?' do
	#markdown params[:obj].to_sym
	haml :markdown, layout: false, locals: {path: params[:obj].to_sym}
end