# Coding:UTF-8

before '/search*' do
	require_login
end

get '/search/?' do
	if keyword = params[:keyword]
		redirect to("/search/#{URI.escape keyword}")
	end

	haml :search, locals: {path: "search", title: "検索"}
end

get '/search/:keyword?' do
	keyword = params[:keyword]
	query = "%#{keyword}%"

	files_result =
		[UploadedFile.public, user_data.uploaded_files.available] \
		.map {|selector| selector.all(:orig_file_name.like => query) } \
		.inject{|a, b| a | b }

	mylists_result =
		[Mylist.public, user_data.mylists.available] \
		.map {|selector| selector.all(:title.like => query) } \
		.inject{|a, b| a | b }

	haml :search, locals: {
		path: "search", title: "検索 - #{keyword}" ,
		files_result: files_result, mylists_result: mylists_result, keyword: h(params[:keyword])
	}
end
