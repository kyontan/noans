# Coding:UTF-8

get "/css/*.css" do
	base_name = settings.views + "/" + params[:splat].first

	if File.exists?(base_name + ".css")
		send_file base_name + ".css"
	elsif File.exists?(base_name + ".scss")
		scss params[:splat].first.to_sym
	else
		halt 404
	end
end
