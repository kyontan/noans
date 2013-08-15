#-*- Coding:UTF-8 -*-

before '/files/*' do
	require_login
end

get '/files/:folder/:filename' do
	begin
		filegroup = FileGroup.where(folder_name: params[:folder]).first
		uploadedfile = filegroup.uploadedFiles.where(file_name: params[:filename]).first
		uploadedfile.access_count ||= 0
		uploadedfile.access_count += 1
		uploadedfile.save!
	rescue
		halt 404
	end
	send_file File.join(settings.root, "uploaded_files", params[:folder], params[:filename])
end

before '/preview/*' do
	require_login
end

get '/preview/:folder/:filename' do
	begin
		filegroup = FileGroup.where(folder_name: params[:folder]).first
		uploadedfile = filegroup.uploadedFiles.where(file_name: params[:filename]).first
		uploadedfile.access_count ||= 0
		uploadedfile.access_count += 1
		uploadedfile.save!
	rescue
		halt 404
	end
	haml :markdown, locals: {
		common_css: true,
		path: "markdown",
		folder: params[:folder],
		filename: params[:filename]
	}
	#send_file File.join(settings.root, "uploaded_files", params[:folder], params[:filename])
end



get '/upload/?' do
	redirect_to "/uploads"
end

before '/uploads/?' do
	require_login(true)
end

get '/uploads/?' do
	haml :uploads, locals: {path: "uploads", title: "アップロード"}

end

post '/uploads/?' do
	# form do
	# 	field :title,		present: true
	# 	field "file[]",		present: true
	# end

	# halt 500 if form.failed?

	require 'securerandom'
	require 'fileutils'

	def filename_escape(f, to = ?-)
		# Escape target: /\:*?"<>|#{}%&~,;
		f.gsub(/\/|\\|:|\*|\?|\"|<|>|\||#|\{|\}|%|&|~|,|;|\s/, to)
	end

	# def filename_split(f)
	# 	[f[0 .. -(File.extname(f).size+1)], File.extname(f)]
	# end

	def get_uuid
		SecureRandom.uuid[23..-1]
	end

	# def join_uuid(f)
	# 	split = filename_split(f)
	# 	joined = split[0] + get_uuid + split[1]
	# end

	filegroup = FileGroup.new(
		title: 				params[:title],
		folder_name:	filename_escape(params[:title] + get_uuid),
		#tags:					params[:tags].split(?,),
		user:					user_data)
	filegroup.save!

	save_to = File.join(settings.root, "uploaded_files", filegroup.folder_name)
	FileUtils.mkdir(save_to)

	params[:file].each do |f|
		# SecureRandom.uuid => "999563cf-4ff8-4dbf-b602-9ac0fce2b0c6"
		# SecureRandom.uuid[23..-1] => "-9ac0fce2b0c6"

		filename = filename_escape(f[:filename])
		#filename = join_uuid(filename_escape(f[:filename]))
		saved_path = File.join(save_to, filename)

		File.write(saved_path, f[:tempfile].read)

		UploadedFile.new(
    	file_name:	filename,
    	type:				f[:type],
    	saved_path:	saved_path,
    	fileGroup:	filegroup
  	).save!

	end

	redirect_to ?/
end

# before '/update/*' do
# 	require_login
# end

# post "/update/tags/?" do
# 	form do
# 		field :id,		present: true
# 		field :tags,	present: true
# 	end
# 	"Form failed.".to_json if form.failed?

# 	filegroup = FileGroup.where(id: params["id"]).first

# 	if filegroup.nil? || filegroup.user != user_data
# 		"error - FileGroup not exists or You're not allowed to edit tags".to_json
# 	else
# 		filegroup.tags = params["tags"].map{|x| h(x)}
# 		filegroup.save!
# 		"success".to_json
# 	end
# end

# before '/tags/*' do
# 	require_login(true)
# end

# get '/tags/:tags/?' do
# 	tags = params["tags"]
# 	halt 404 if tags.nil? || tags.empty?
# 	FileGroup.where(:tags.in => tags.split(?&)).to_a.map(&:title)
# end

get "/css/:stylesheet.css" do
	scss params[:stylesheet].to_sym

	# begin

	# rescue
	# 	content_type :css
	# 	send_file "./views/#{params[:stylesheet]}.css"
	# end
end

get '/:file.css' do
	redirect_to "/css/#{params[:file]}.css"
end