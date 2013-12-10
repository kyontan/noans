# Coding:UTF-8

# before '/upload*' do
# 	require_login(true)
# end

get '/upload/?' do
# get '/upload/:mylist_id?/?' do
	haml :upload, locals: {path: "upload", title: "ファイル - アップロード"}
end

post '/upload/?' do
# post '/upload/:mylist_id?/?' do
	# require 'fileutils'
	# mylist = Mylist.new
	# mylist.user			= user_data
	# mylist.title		= params[:title]
	# mylist.comment	= params[:comment]
	# mylist.public		= (params[:public] == "on") # ? true : false
	# raise unless mylist.save
	# path = Pathname(settings.root) + "uploads" + mylist.title

	path = Pathname(settings.root) + "uploads"

	params[:file].each do |f|
		sha2 = Digest::SHA2.hexdigest(File.read(f[:tempfile].path))
		next if user_data.uploaded_files.available.first(orig_file_name: h(f[:filename]), sha2: sha2)

		file = UploadedFile.new
		# file.file_group = filegroup
		file.user						= user_data
		file.file_type			= h(f[:type])
		file.file_size			= f[:tempfile]
		file.orig_file_name = h(f[:filename])
		file.sha2						= sha2
		file.public					= params[:public] ? true : false
		raise unless file.save

		File.write(
			(path + "#{file.file_name}").to_s,
			f[:tempfile].read
		)

		# file.file_type	= get_mime_type(f[:filename])
		raise unless file.update(uploaded: true)

		# if mylist_id = params[:mylist_id]
		# 	mylist = Mylist.get(mylist_id)
		# 	mylist.uploaded_files << file
		# 	raise unless mylist.save
		# end
	end

	haml :upload, locals: {path: "upload", title: "ファイル - アップロード", succeed: true}
end
