# Coding:UTF-8

get '/register/?' do
	haml :register, locals: {path: "register", title: "ユーザ登録"}
end

post '/register/?' do
	if !session[:uuid].nil? && (user = User.first(uuid: session[:uuid]))
		halt unless user.draft # user.uuid may not be known anybody!

		user.destroy
	end
	session.delete(:uuid)


	user = User.new(
		user_name: h(params[:user_name]),
		password: params[:password],
		password_confirm: params[:password_confirm],
		mail: h(params[:mail])
	)

	unless user.valid?
		errors = flat_map2(user.errors.to_h){|s| dic_sub(s, User.key_translation)}
		errors.default = []
		haml :register, locals: {path: "register", title: "ユーザ登録", errors: errors}
	else
		user.save
		session[:uuid] = user.uuid

		haml :register_confirm, locals: {path: "register_confirm", title: "ユーザ登録 - 確認"}
	end
end

post '/register/process/?' do
	redirect to "/register" unless session[:uuid] && (user = User.first(uuid: session[:uuid]))

	if user.update(draft: false)
		session[:user_name] = user.user_name
		session.delete(:uuid)

		LoggedActivity.create(user: user_data, type: "login")
		redirect to "/"
	else
		halt "user isn't valid!"
	end

end


# before '/register/confirm/?' do
# 	check_csrf
# end

# post '/register/confirm/?' do
# 	form do
# 		field :name,			present: true
# 		field :id,				present: true, length: 4..255, alnum: true
# 		field :password,	present: true, length: 6..255
# 		field :email, 		email:	 true
# 	end

# 	duplicate = {
# 		id: 	User.where(user_id: params[:id]).exists?,
# 		mail: User.where(mail: params[:mail]).exists? && !params[:mail.empty?]
# 	}

# 	if form.failed? || duplicate.value?(true)
# 		session[:form_error] = {}
# 		params.each{|k, v| session[:form_error][k.to_sym] = h(v) }
# 		# params.each do |key, value|
# 		# 	session[:form_error][key.to_sym] = h(value)
# 		# end
# 		session[:form_error][:duplicate] = duplicate
# 		session[:form_error][:redirect] = true
# 		redirect to "/register/"
# 	else
# 		form.each {|k, v| form[k] = h(v)}
# 		params_copy = form.clone
# 		params_copy.default = nil
# 		session[:form_confirm] = params_copy.clone
# 		haml :register_confirm, locals: {path: "register_confirm", title: "新規登録"}

# 	end
# end
