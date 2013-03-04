#-*- Coding:UTF-8 -*-

get '/upload/?' do
	redirect "#{@root_dir}/uploads"
end

get '/uploads' do
	require_login(true)

	haml :uploads, locals: {path: "uploads", title: "アップロード"}
end
