
before '/user*' do
	require_login
end

# get '/users/?' do
# 	require_login(true)

# 	User.all.to_json
# end

get '/user/:user_name/?' do
	if user = User.get(params[:user_name])
		if user == user_data
			redirect to("/my")
		else
			haml :user_page, locals: {path: "user_page", title: "ユーザー - #{user.user_name}", user: user}
		end
	else
		error 404
	end
end

before '/my*' do
	require_login
end

get '/my/:mylist/upload/?' do
	redirect to "/upload/#{params[:mylist]}/?"
end

get '/user/:user/:mylist/*?' do
	redirect to "/mylist/#{params[:mylist]}/#{params[:splat].join(?/)}"
end

