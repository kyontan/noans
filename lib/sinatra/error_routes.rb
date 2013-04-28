#!/usr/local/bin/ruby

require 'sinatra/base'
require 'sinatra/usual_helpers'

module Sinatra
	module ErrorRoutes
		def self.registered(app)
			app.set inline_templates: true

			app.error 401 do
				haml :default_error, layout: false,
							locals: {image: "/e/Response_401.png", code: 401, res: "Authorization Required"}
			end

			app.error 403 do
				haml :default_error, layout: false,
							locals: {image: "/e/Response_403.png", code: 401, res: "Forbidden"}
			end

			app.error 404 do
				haml :default_error, layout: false,
							locals: {image: "/e/Response_404.png", code: 404, res: "Not Found"}
			end

			app.error 500 do
				haml :default_error, layout: false,
							locals: {image: "/e/Response_500.png", code: 500, res: "Internal Server Error"}
			end

			app.error 418 do
				#haml :'418'
				haml :default_error, layout: false,
							locals: {image: "#{request.script_name}/teapot.png", code: 418, res: "I'm a teapot",
							mes: "I'm a teapot!"}
			end
		end
	end

	register ErrorRoutes
end

# require 'rack/csrf'
# error Rack::Csrf::InvalidCsrfToken do
#    #"CSRFが検出されました。"
#    "CSRF!"
# #    # @specific_object = :CSRF
# #    # @common_css = true
# #    # haml :common
# end

__END__
@@default_error
!!!5
%html
	%head
		%meta(charset = "utf-8")
		%title #{code} #{res}

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
	%body
		%div.response #{code} #{res}
		%img(src="#{image}" alt="#{code} #{res}")
		- unless (mes ||= nil).nil?
			%br
			= mes
			%br
		%a{href(?/)} TOPへ
		%div.footer
			CopyRight (C) 2010-2012 monora.me... Some rights reserved.