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
