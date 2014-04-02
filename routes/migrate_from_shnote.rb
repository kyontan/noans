# Coding:UTF-8

before '/migrate*' do
	# halt unless request.secure?
	require_login
end

get '/migrate/user_available' do
	{available: User.get(params[:user_name]).nil?}.to_json
end
