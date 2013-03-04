#-*- Coding:UTF-8 -*-

get '/admin/?' do
	require_login(true)

	haml :admin, locals: {path: "admin", title: "管理画面"}
end

post '/admin/set/post/?' do
	require_login(true)
	redirect "#{@root_dir}/admin/" if params[:post] == ""

	user = User.where(user: session[:user_data][:user]).first
	user.posts << Post.new(text: params[:post], showtop: true)

	redirect "#{@root_dir}/admin/"
end

post '/admin/set/text/?' do
	require_login(true)
	redirect "#{@root_dir}/admin/" if params[:text] == ""

	redis.set("text", params[:text])

	redirect "#{@root_dir}/admin/"
end