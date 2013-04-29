#!/usr/local/bin/ruby

require 'sinatra/base'

module Sinatra
	module UsualHelpers
		def link_to(to)
			request.script_name + to
		end

		def redirect_to(to)
			redirect link_to(to)
		end
	end
	helpers UsualHelpers
end