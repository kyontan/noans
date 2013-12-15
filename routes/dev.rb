# Coding: UTF-8

before '/dev*' do
	require_login(true)
end

get '/dev/?' do
	haml :dev, locals: {common_css: true, title: "開発用"}
end

get '/dev/raise/?' do
	raise "Raise for debugging"
end

get '/dev/error/:error_status/?' do
	halt params[:error_status].to_i
end

get %r(/dev/([0-9]{3})/?) do
	status = params[:captures].first.to_i
	halt status
end

get '/dev/render/:obj/?' do
	haml params[:obj].to_sym,
				locals: {
			 		path: params[:obj],
			 		params: Hash.new(""),
			 		title: "dev render - #{params[:obj]}"
			 	}
end

get '/dev/render_without_layout/:obj/?' do
	haml params[:obj].to_sym, layout: false,
				locals: {
			 		path: params[:obj],
			 		params: Hash.new(""),
			 		title: "dev render - #{params[:obj]}"
			 	}
end

get '/dev/raise/?' do
	raise
end

get '/dev/reset/?' do
	system("touch ./tmp/restart.txt")

	redirect back
end
