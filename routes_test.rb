#-*- Coding:UTF-8 -*-

before '/test*' do
	require_login(true)
end

get '/test/?' do
	haml :test, locals: {common_css: true}
end

get '/test/error/:error_status/?' do
	halt params[:error_status].to_i
end

get %r{/test/([0-9]{3})/?} do
	status = params[:captures].first.to_i
	halt status
end

get '/test/render/:obj/?' do
	haml :"#{params[:obj]}",  :layout => false,
			 locals: {path: params[:obj], title: "Test render - #{params[:obj]}", locals: {params: Hash::new("")}}
end

get '/test/user_data/:spec/?' do
	eval "UserData.#{params[:spec]}"
end

get '/test/session/get/?' do
	session[:test]
end

get '/test/session/set/?' do
	session[:test] = "Sessioned! #{Time.now}"
	redirect '#{@root_dir}/session/get'
end

get '/test/session/clear/?' do
	session[:test] = nil
end

get '/test/post/?' do
	"Post"
end


get '/test/raise/?' do
	raise "Raise for debugging"
end

get '/test/reset/?' do
	require_login(true)

	system("touch ./tmp/restart.txt")

	redirect_url = request.referer == '/' ? @root_dir : request.referer
	redirect redirect_url if $?.exitstatus == 0
	#redirect @root_dir if $?.exitstatus == 0
	"#{$?.exitstatus} <a href='#{link_to ?/}'>back</a>"
end

#set :inline_template :true
before '/test/md/' do
	require 'rdiscount'
end

get '/test/md/:obj/?' do
	#markdown params[:obj].to_sym
	haml :markdown, :layout => false, locals: {path: params[:obj].to_sym}
end