#-*- Coding:UTF-8 -*-

get '/test' do
	haml :test
end

get '/test/error/:error_status' do
	halt params[:error_status].to_i
end

get '/test/render/:obj/?' do
	haml params[:obj].to_sym, locals: {path: params[:obj]}
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

#set :inline_template :true
before '/test/md/' do
	require 'rdiscount'
end

get '/test/raise/?' do
	raise "oops"
end

get '/test/reset/?' do
	require_login(true)

	system("touch ./tmp/restart.txt")

	redirect_url = request.referer == '/' ? @root_dir : request.referer
	redirect redirect_url if $?.exitstatus == 0
	#redirect @root_dir if $?.exitstatus == 0
	"#{$?.exitstatus} <a href='#{@root_dir}'>back</a>"
end

get '/test/md/:obj/?' do
	#markdown params[:obj].to_sym
	haml :markdown, :layout => false, locals: {path: params[:obj].to_sym}
end