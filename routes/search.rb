# Coding:UTF-8

before '/search*' do
	require_login
end

get '/search/?' do
	if keyword = params[:keyword]
		redirect to("/search/#{keyword}")
	end

	haml :search, locals: {path: "search", title: "検索", common_css: true}
end

get '/search/:keyword?' do
	keyword = params[:keyword]

	files_result = UploadedFile.available.all(:orig_file_name.like => "%#{keyword}%")
	files_result = files_result | user_data.uploaded_files.available.all(:orig_file_name.like => "%#{keyword}%")

	mylists_result = Mylist.available.all(:title.like => "%#{keyword}%")
	mylists_result = mylists_result | user_data.mylists.available.all(:title.like => "%#{keyword}%")

	haml :search, locals: {
		path: "search", title: "検索 - #{keyword}" , common_css: true,
		files_result: files_result, mylists_result: mylists_result, keyword: h(params[:keyword])
	}
end
