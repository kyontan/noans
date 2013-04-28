#-*- Coding:UTF-8 -*-

get '/admin/?' do
	require_login(true)

	haml :admin, locals: {path: "admin", title: "管理画面"}
end

post '/admin/set/post/?' do
	require_login(true)
	redirect_to "/admin/" if params[:post].empty?

	#user = User.where(id: session[:id]).first
	#user.posts << Post.new(text: params[:post], showtop: true)
	userData.posts << Post.new(text: params[:post], showtop: true)

	redirect_to "/admin/"
end

post '/admin/set/text/?' do
	require_login(true)
	redirect_to "/admin/" if params[:text].empty?

	redis.set("text", params[:text])

	redirect_to "/admin/"
end
