# Coding: UTF-8

get '/about/?' do
	haml :markdown, locals: {path: "markdown", title: "About", obj: :"about"}
end

get '/terms-of-service/?' do
	haml :markdown, locals: {path: "markdown", title: "Terms of Service", obj: :"terms-of-service"}
end

get '/privacy-policy/?' do
	haml :markdown, locals: {path: "markdown", title: "Privacy Policy", obj: :"privacy-policy"}
end

get "/css/*.css" do
	file_name = params[:splat].first
	views =  Pathname(settings.views)

	if File.exists?(views + "#{file_name}.css")
		send_file views + "#{file_name}.css"
	elsif File.exists?(views + "#{file_name}.scss")
		scss file_name.to_sym
	else
		halt 404
	end
end
