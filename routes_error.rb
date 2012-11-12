#-*- Coding:UTF-8 -*-
error 404 do
	content_type :html

text = <<-'EOF'
!!!5
%html
	%head
		%meta(charset = "utf-8")
		%title 404 Not Found

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
		%div.response 404 Not Found
		%img(src="/e/Response_404.png" alt="404 Not Found")
		%a(href="/") TOPへ
		%div.footer
			CopyRight (C) 2010-2012 monora.me... Some rights reserved.
EOF

haml text
end

error 418 do
	content_type :html, :charset => 'utf-8'

text = <<-"EOF"
!!!5
%html
	%h2 418 - I'm a teapot.
	%img(src = "#{request.script_name}/teapot.png")
EOF
#'

	haml text
end

#Not working?
error Rack::Csrf::InvalidCsrfToken do
   "CSRF exception!!"
end