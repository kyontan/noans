# Coding:UTF-8

before '/login/?' do
	redirect to ?/ if logged_in?
end

get '/login/?' do
	haml :login, locals: {path: "login", title: "ログイン"}
end

post '/login/?' do

	# params_filled = params_filled?([:id, :password])
	# redirect to "/login/" unless params_filled

	if login!(params[:user_name], params[:password])
		redirect to ?/
	else
		haml :login, locals: {path: "login", title: "ログイン", error: true}
	end
end

before '/logout/?' do
 	redirect back unless logged_in?
end

get '/logout/?' do
	logout!
	redirect to ?/
end
