require 'haml'

module Haml
	module Helpers
		# HTML5 Time element helper
		# Usage:
		# 	%time{time(Time)}(pubdate)
		#  	#=> <time datetime="2012-11-18T17:47:36.000-JST" pubdate></time>
		def time(t)
			{datetime: t.strftime("%Y-%m-%dT%H:%M:%S.%3N-%Z")}
		end

		# Link helper
		# Usage:
		# 	%a{href("/nyaa")}
		# 	=> <a href="/app/root/nyaa"></a>
		def href(to)
			{href: to(to)}
		end

		def action(to)
			{action: to(to)}
		end


		def src(to)
			{src: to(to)}
		end

	end
end