get '/register/?' do
	haml :register, locals: {path: "register", title: "新規登録"}
end

before '/register/confirm/?' do
	check_csrf
end

post '/register/confirm/?' do
	form do
		field :name,			present: true
		field :id,				present: true, length: 4..255
		field :password,	present: true, length: 6..255
		field :email, 		email:	 true
	end

	duplicate = {
		id: 	User.where(user_id: params[:id]).exists?,
		mail: User.where(mail: params[:mail]).exists? && !params[:mail.empty?]
	}

	if form.failed? || duplicate.value?(true)
		session[:form_error] = {}
		params.each{|k, v| session[:form_error][k.to_sym] = h(v) }
		# params.each do |key, value|
		# 	session[:form_error][key.to_sym] = h(value)
		# end
		session[:form_error][:duplicate] = duplicate
		session[:form_error][:redirect] = true
		redirect_to "/register/"
	else
		params.each {|k, v| params[k] = h(v)}
		params_copy = params.clone
		params_copy.default = nil
		session[:form_confirm] = params_copy.clone
		haml :register_confirm, locals: {path: "register_confirm", title: "新規登録"}

	end
end

post '/register/process/?' do
	halt 500 if session[:form_confirm].nil?
	data = session[:form_confirm]
	halt 500 if User.where(user_id: data[:id]).exists?

	password, salt = password_hash(data["password"])

	user = User.new(
    display_name:	data["name"],
    user_id: 			data["id"],
		password: 		password,
		salt: 				salt,
		mail: 				data["mail"])

	begin
		user.save!
	rescue
		halt 500
	end
	session[:form_confirm] = nil
	haml :register_completed, locals: {path: "register_completed", title: "登録完了"}
end
