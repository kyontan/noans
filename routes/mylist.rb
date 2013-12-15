# Coding:UTF-8

before '/mylist*' do
	require_login
end

get '/mylists/?' do
	require_login(true)

	Mylist.all.to_json
end

get '/mylist/new/?' do
	haml :mylist_new, locals: {path: "mylist_new", title: "マイリスト - 作成"}
end

post '/mylist/new/?' do
	mylist = Mylist.new(
		title: 		h(params[:title]),
		comment:	h(params[:comment]),
		public:		params[:public] ? true : false,
		user: 		user_data
	)

	if mylist.save
		redirect to("/mylists/#{mylist.id}")
	else
		errors = flat_map2(mylist.errors.to_h){|s| dic_sub(s, Mylist.key_translation) }
		errors.default = []
		haml :mylist_new, locals: {path: "mylist_new", title: "マイリスト - 作成", errors: errors}
	end

end

get '/mylists/:id/?' do
	if mylist = Mylist.first(id: params[:id])
		if mylist.public || mylist.user == user_data
			haml :mylist, locals: {path: "mylist", title: "マイリスト - #{mylist.title}", mylist: mylist}
		else
			halt 403
		end
	else
		halt 404
	end
end

get '/mylist/:mylist_id/add/?' do
	mylist_id = params[:mylist_id]
	mylist = Mylist.get(mylist_id)
	halt 404 unless mylist || mylist.available
	halt 403 if mylist.user != user_data

	haml :mylist_add, locals: {path: "mylist_add", title: "マイリスト - 追加", mylist: mylist}
end

post '/mylist/:mylist_id/add/?' do
	mylist_id = params[:mylist_id]
	mylist = Mylist.get(mylist_id)
	halt 404 unless mylist || mylist.available
	halt 403 if mylist.user != user_data


	params.keys.select{|x| /\d+/ === x}.each do |f|
		file = UploadedFile.get(f)
		mylist.uploaded_files << file
		raise unless mylist.save
	end

	redirect to("/mylists/#{mylist.id}")
end

get '/mylist/:mylist_id/edit/?' do
	mylist_id = params[:mylist_id]
	mylist = Mylist.get(mylist_id)
	halt 404 unless mylist || mylist.available
	halt 403 if mylist.user != user_data

	haml :mylist_edit, locals: {path: "mylist_edit", title: "マイリスト - 編集", mylist: mylist}

end

post '/mylist/:mylist_id/edit/?' do
	mylist_id = params[:mylist_id]
	mylist = Mylist.get(mylist_id)
	mylist_orig = mylist.clone

	halt 404 unless mylist || mylist.available
	halt 403 if mylist.user != user_data

	mylist.title		= h(params[:title]) if params[:title]
	mylist.comment	= h(params[:comment]) if params[:comment]
	# mylist.public		= params[:public] ? true : false

	params.keys.select{|k| /^\d+$/ === k }.map(&:to_i).each do |k|
		file = UploadedFile.get(k)
		halt 403 unless file || file.available || file.user == user_data

		mylist.uploaded_files.delete(file)
	end

	if mylist.save
		haml :mylist_edit, locals: {path: "mylist_edit", title: "マイリスト - 編集", mylist: mylist, succeed: true}
	else
		errors = flat_map2(mylist.errors.to_h){|s| dic_sub(s, Mylist.key_translation) }
		errors.default = []
		haml :mylist_edit, locals: {path: "mylist_edit", title: "マイリスト - 編集", mylist: mylist_orig, errors: errors}
	end
end

get '/mylist/:mylist_id/remove/?' do
	mylist_id = params[:mylist_id]
	mylist = Mylist.get(mylist_id)
	halt 404 unless mylist || mylist.available
	halt 403 unless mylist.user == user_data

	haml :mylist_remove, locals: {path: "mylist_remove", title: "マイリスト - 削除", common_css: true, mylist: mylist}

end

post '/mylist/:mylist_id/remove/?' do
	mylist_id = params[:mylist_id]
	mylist = Mylist.get(mylist_id)
	halt 404 unless mylist || mylist.available
	halt 403 unless mylist.user == user_data

	halt unless mylist.update(deleted: true)

	haml :mylist_remove, locals: {path: "mylist_remove", title: "マイリスト - 削除", common_css: true, succeed: true}

end
