#!/usr/local/bin/ruby

require 'sinatra/base'

module Sinatra
	module UsualHelpers
		def self.registered(app)
			app.alias_method :h, :escape_html
		end

		def link_to(to)
			request.script_name + to #@root_dir
		end

		def redirect_to(to)
			redirect link_to(to)
		end
	end
	helpers UsualHelpers
end