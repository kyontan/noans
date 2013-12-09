# Coding: UTF-8

require 'sinatra/base'

module Sinatra
	module UsualHelpers
		def link_to(to)
			request.script_name + to
		end

		# def redirect_to(uri)
		# 	redirect to(to)
		# end
	end
	helpers UsualHelpers
end