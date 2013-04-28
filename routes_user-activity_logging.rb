get '/login/?' do
	haml :login, locals: {path: "login", title: "ログイン"}
end

post '/login/?' do
	form do
		filters :strip
		field :id,				present: true
		field :password,	present: true
	end

	redirect_to "/login/" if form.failed?

	params.each {|k, v| params[k] = h(v)}

	db_user = User.where(user_id: params[:id]).to_a.first

	hash = password_hash(params[:password], db_user.salt)[0]

	if db_user.nil? || db_user.password != hash
		redirect_to "/login/"
	else
		session[:id] = db_user.id
		userData.loggedActivities << LoggedActivity.new(type: "login", ip: request.ip)
		redirect_to ?/
	end
end

get '/logout/?' do
	userData.loggedActivities << LoggedActivity.new(type: "logout", ip: request.ip)
	session[:id] = nil
	redirect_to ?/
end
