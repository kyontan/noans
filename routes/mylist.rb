# Coding:UTF-8

before '/mylist/*' do
	require_login

	pass if %r{/mylist/new/?} === request.path

	# @id = params[:id]
	@id = request.path.match(%r{/mylist/(\d+)/?})[1]
	@mylist = Mylist.get(@id)
	halt 404 if @mylist.nil?
	halt 410 if @mylist.deleted

	pass if %r{/mylist/:id/?$} === request.path

	halt 403 unless @mylist.public || @mylist.user == user_data
end

get '/mylists/?' do
	require_login(true)

	Mylist.all.to_json
end

get '/mylist/new/?' do
	haml :mylist_new, locals: {path: "mylist_new", title: "マイリスト - 作成"}
end

post '/mylist/new/?' do
	@mylist = Mylist.new(
		title: 		h(params[:title]),
		comment:	h(params[:comment]),
		public:		params[:public] ? true : false,
		user: 		user_data
	)

	if @mylist.save
		redirect to("/mylist/#{@mylist.id}")
	else
		errors = flat_map2(@mylist.errors.to_h){|s| dic_sub(s, Mylist.key_translation) }
		errors.default = []
		haml :mylist_new, locals: {path: "mylist_new", title: "マイリスト - 作成", errors: errors}
	end

end

get '/mylist/:id/?' do
	if @mylist.public || @mylist.user == user_data
		haml :mylist, locals: {path: "mylist", title: "マイリスト - #{@mylist.title}"}
	else
		halt 403
	end
end

get '/mylist/:id/add/?' do
	haml :mylist_add, locals: {path: "mylist_add", title: "マイリスト - 追加"}
end

post '/mylist/:id/add/?' do
	params.keys.select{|x| /\d+/ === x}.each do |f|
		file = UploadedFile.get(f)
		halt 500 unless file || file.available

		@mylist.uploaded_files << file

		halt 500 unless @mylist.save
	end

	redirect to("/mylist/#{@mylist.id}")
end

get '/mylist/:id/edit/?' do
	haml :mylist_edit, locals: {path: "mylist_edit", title: "マイリスト - 編集"}
end

post '/mylist/:id/edit/?' do
	orig = @mylist.clone

	@mylist.title		= h(params[:title]) if params[:title]
	@mylist.comment	= h(params[:comment]) if params[:comment]
	# @mylist.public		= params[:public] ? true : false

	params.keys.select{|k| /^\d+$/ === k }.map(&:to_i).each do |k|
		file = UploadedFile.get(k)
		halt 500 unless file || file.available || file.user == user_data

		@mylist.uploaded_files.delete(file)
	end

	if @mylist.save
		haml :mylist_edit, locals: {path: "mylist_edit", title: "マイリスト - 編集", succeed: true}
	else
		errors = flat_map2(@mylist.errors.to_h){|s| dic_sub(s, Mylist.key_translation) }
		errors.default = []
		haml :mylist_edit, locals: {path: "mylist_edit", title: "マイリスト - 編集", mylist: orig, errors: errors}
	end
end

get '/mylist/:id/remove/?' do
	haml :mylist_remove, locals: {path: "mylist_remove", title: "マイリスト - 削除"}
end

post '/mylist/:id/remove/?' do
	halt unless @mylist.update(deleted: true)

	haml :mylist_remove, locals: {path: "mylist_remove", title: "マイリスト - 削除", succeed: true}
end
