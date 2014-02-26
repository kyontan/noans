# Coding: UTF-8

require 'sinatra/base'
require 'sinatra/usual_helpers'

module Sinatra
	module ErrorRoutes
		def self.registered(app)
			app.error 401 do
				haml :default_error, layout: false,
							locals: {mes: "Authorization Required"}
			end

			app.error 403 do
				haml :default_error, layout: false,
							locals: {mes: "Forbidden"}
			end

			app.error 404 do
				haml :default_error, layout: false,
							locals: {mes: "Not Found"}
			end

			app.error 410 do
				haml :default_error, layout: false,
							locals: {mes: "Gone"}
			end

			app.error 500 do
				haml :default_error, layout: false,
							locals: {mes: "Internal Server Error"}
			end

			app.template :default_error do
<<'EOF'
!!!
%html
	%meta(charset = "utf-8")
	%title #{status} #{mes}

	:scss
		body {
			font-size: 16px;
			line-height: 1;

			width: 480px;
			margin: 30px auto 0;
		}

		a {
			display: inline-block;
			font-size: 1.2em;
			text-decoration: none;

			color: #888;
			transition: .5s;
			border-bottom: 1px solid transparent;

			&:hover {
				transition: .2s;
				border-bottom-color: #888;
			}

			&#link-top {
				float: right;
			}
		}

		.mes {
			font-family: "Source Code Pro", monospace;
			font-size: 28px;
			text-shadow: #eee 1px 1px 12px;
			text-align: center;

			background: white;
			margin-bottom: 36px;
			padding: 12px 0;
			border: 6px solid #eee;
			border-radius: 16px;

			box-sizing: border-box;
			box-shadow: #fcfcfc 3px 3px 12px;
			-webkit-box-reflect: below 1px linear-gradient(to bottom, transparent, rgba(255, 255, 255, .02) 99%);
		}

		.footer {
			margin-top: 20px;
			padding: 6px 0;

			border-image: linear-gradient(to left, #fff, #ccc, #fff) 1;
			border-width: 1px;

			font-size: 12px;
			text-align: center;
			color: #888;
		}

	%div.mes #{status} #{mes}

	%a(href = "javascript:history.back()") 戻る
	%a#link-top{href(?/)} TOPへ
	%div.footer noans © 2012- Created by kyontan
EOF
			end
		end
	end

	register ErrorRoutes
end

