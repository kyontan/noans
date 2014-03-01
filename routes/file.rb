# Coding: UTF-8

before "/file/*" do
	require_login

	_, @id, _, @file_name = request.path.match(%r{/file.*?/(\d+)(/?|/(.+))$}).to_a # /file(/...)/<1234>/(<komari.image>)
	@file = UploadedFile.get(@id)

	halt 404 if @file.nil?
	halt 404 unless @file_name.nil? || @file.orig_file_name == URI.decode(@file_name).force_encoding("UTF-8")
	halt 410 if @file.deleted
	halt 403 unless @file.public || @file.user == user_data
end

get "/files/?" do
	require_login(true)

	UploadedFile.all.to_json
end

get "/files/manage/?" do
	haml :files_manage, locals: {path: "files_manage", title: "ファイル - 管理"}
end

post "/files/manage/?" do
	keys = params.keys.inject(Hash.new([])) do |hash, p|
	 _, k, n = p.match(/(.+)-(\d+)/).to_a # <public>-<1>
	 hash[k.to_sym] += [n.to_i] unless k.nil?
	 hash
	end

	user_data.uploaded_files.available.each do |file|
		id = file.id
		halt 500 unless file.update(deleted: true) if keys[:delete].include?(id)
		halt 500 unless file.update(public: keys[:public].include?(id))
	end

	haml :files_manage, locals: {path: "files_manage", title: "ファイル - 管理", succeed: true}
end

get "/file/preview/:id/:file_name?" do
	halt 415 unless %r{.(md|mdown|markdown)$} === @file.orig_file_name

	if @file_name
		haml :markdown_preview, locals: {path: "markdown_preview", title: @file.orig_file_name}
	else
		redirect to(URI.encode("/file/preview/#{@file.id}/#{@file.orig_file_name}"))
	end
end

get "/file/:id/:file_name?" do
	if @file_name
		@file.update(access_count: @file.access_count+1)
		send_file Pathname(settings.root) + "uploads" + @file.file_name
	else
		redirect to(URI.encode("/file/#{@file.id}/#{@file.orig_file_name}"))
	end
end
