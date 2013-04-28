require 'haml'

module Haml
	module Helpers
		#HTML5 Time element helper
		#Usage:
		#	%time{time(Time)}(pubdate)
		# => <time datetime="2012-11-18T17:47:36.000-JST" pubdate></time>
		def time(t)
			{datetime: t.strftime("%Y-%m-%dT%H:%M:%S.%3N-%Z")}
		end

		#Form action
		#Usage: %form{action("/login")}
		# => <form action="/app/root/login"></form>
		def action(to)
			{action: link_to(to)}
		end

		#Link helper
		#Usage: %a{href("/nyaa")}
		# => <a href="/app/root/nyaa"></a>
		def href(to)
			{href: link_to(to)}
		end

		#protected #?
		def link_to(to)
			request.script_name + to #@root_dir
		end
	end
end