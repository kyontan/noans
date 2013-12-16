# Coding: UTF-8

before '/files*' do
	require_login
end

get '/files/?' do
	require_login(true)

	UploadedFile.all.to_json
end

get '/files/manage/?' do
	haml :files_manage, locals: {path: "files_manage", title: "ファイル - 管理"}
end

post '/files/manage/?' do
	succeed = false

	def select_with_regexp(keys, reg)
		keys.select{|k| reg === k }.map{|k| k.match(reg)[1].to_i }
	end

	# mark public
	public_keys = select_with_regexp(params.keys, /^public-(\d+)$/)
	public_keys.each do |k|
		file = UploadedFile.get(k)
		halt 403 unless file || file.available || file.user == user_data

		raise unless file.public || file.update(public: true)
		succeed = true
	end

	# mark un-pablic
	(user_data.uploaded_files.available.map(&:id) - public_keys).each do |k|
		file = UploadedFile.get(k)
		halt 403 unless file || file.available || file.user == user_data

		raise if file.public && !file.update(public: false)
		succeed = true
	end

	# mark removed
	select_with_regexp(params.keys, /^remove-(\d+)$/).each do |k|
		file = UploadedFile.get(k)
		halt 403 unless file || file.available || file.user == user_data

		raise unless file.update(deleted: true)
		succeed = true
	end

	haml :files_manage, locals: {path: "files_manage", title: "ファイル - 管理", succeed: succeed}
end

get '/files/preview/:id/:file_name?' do
	file_id = params[:id]
	file_name = params[:file_name]

	halt 404 unless file = UploadedFile.get(file_id) and (!file_name || file.orig_file_name == file_name)
	halt 403 unless file.public || file.user == user_data
	halt 415 unless %r{.(md|mdown|markdown)$} === file.orig_file_name

	if file_name
		haml :markdown_preview, locals: {path: "markdown_preview", file: file, title: file.orig_file_name}
	else
		redirect to("/files/preview/#{file_id}/#{file.orig_file_name}")
	end
end

get '/files/:id/:file_name?' do
	file_id = params[:id]
	file_name = params[:file_name]

	halt 404 unless file = UploadedFile.get(file_id) and (!file_name || file.orig_file_name == file_name)
	halt 403 unless file.public || file.user == user_data

	if file_name
		file.update(access_count: file.access_count+1)
		send_file Pathname(settings.root) + "uploads" + file.file_name
	else
		redirect to("/files/#{file_id}/#{file.orig_file_name}")
	end
end
