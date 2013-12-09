# Coding:UTF-8

before '/dev*' do
	#require_login(true)
end

get '/dev/?' do
	haml :dev, locals: {common_css: true, title: "開発用", mode: "get"}
end

post '/dev/?' do
	haml :dev, locals: {common_css: true, title: "開発用", mode: "post", params: params}
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

get '/dev/render2/:obj/?' do
	haml params[:obj].to_sym, layout: false,
				locals: {
			 		path: params[:obj],
			 		params: Hash.new(""),
			 		title: "dev render - #{params[:obj]}"
			 	}
end

get '/dev/user_data/:spec/?' do
	eval "user_data.#{params[:spec]}"
end

# get '/dev/session/get/?' do
# 	session[:dev]
# end

# get '/dev/session/set/?' do
# 	session[:dev] = "Sessioned! #{Time.now}"
# 	redirect "/session/get"
# end

# get '/dev/session/clear/?' do
# 	session[:dev] = nil
# end

# get '/dev/post/?' do
# 	"Post"
# end

get '/dev/raise/?' do
	raise
end

get '/dev/reset/?' do
	require_login(true)

	system("touch ./tmp/restart.txt")

	redirect back
end

get '/dev/md/:md/?' do
	#markdown params[:md].to_sym

	haml :markdown_dev, layout: false, locals: {md: params[:md], title: "dev render - #{params[:md]}.md"}
end

template :markdown_dev do
<<'EOF'
!!!5
%html

	%meta(charset = "utf-8")
	%title Markdown preview - #{md}

	:css
		body {
			width : 425px;
			margin: 30px auto;
		}

		a { color:#888;	}

		.response { display:none; }

		.footer {
			margin-top     : 20px;
			padding-top    : 6px;
			padding-bottom : 6px;
			border-top     : -moz-linear-gradient(left,#fff,#ccc,#fff);
			border-bottom  : -moz-linear-gradient(left,#fff,#ccc,#fff);
			text-align     : center;
			font-size      : 12px;
			color          : #888;
		}

	= markdown md.to_sym
EOF
end