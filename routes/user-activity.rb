# Coding:UTF-8

require_relative 'user-activity_register'
require_relative 'user-activity_logging'

before '/my*' do
	require_login
end

get '/my/?' do
	haml :mypage, locals: {path: "mypage", title: "マイページ"}
end


get '/my/settings/?' do
	haml :profile_settings, locals: {path: "profile_settings", title: "ユーザ情報 - 編集"}
end

post '/my/settings/?' do
	user, validation_case = user_data, :default

	user.mail	= params[:mail] unless params[:mail].empty?

	unless params[:password].empty?
		validation_case = :update_password
		user.password 				= params[:password_new]
		user.password_confirm	= params[:password_new_confirm]
	end

	is_password_valid = (user_data.password == params[:password])
	if is_password_valid && user.valid?(validation_case)
		user.save
		haml :profile_settings, locals: {path: "profile_settings", title: "ユーザ情報 - 編集", completed: true}
	else
		user.valid?(validation_case)

		errors = flat_map2(user.errors.to_h){|s| dic_sub(s, User.key_translation)}
		errors.default = []

		errors[:password_old] = ["パスワードが間違っています"] unless is_password_valid

		haml :profile_settings, locals: {path: "profile_settings", title: "ユーザ情報 - 編集", errors: errors}
	end
end

get '/my/settings/secede/?' do
	haml :profile_secede, locals: {path: "profile_secede"}
	# haml :profile_secede, locals: {path: "profile_secede"}
end

post '/my/settings/secede/?' do
	if user_data.password == params[:password]
		user_data.update(deleted: true)
		session[:user_data] = nil

		haml :profile_secede, locals: {path: "profile_secede", title: "ユーザ - 退会", completed: true}
	else
		haml :profile_secede, locals: {path: "profile_secede", title: "ユーザ - 退会", error: {password: "パスワードが間違っています"}}
	end
end

before '/admin*' do
	require_login(true)
end

get '/admin/?' do
	haml :admin, locals: {path: "admin", title: "管理画面"}
end
