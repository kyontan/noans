#!/usr/local/bin/ruby

require 'sinatra/base'

module Sinatra
	module NoansHelpers
	end
	helpers NoansHelpers

	module SessionHelper
		def userData
			User.where(user: session[:user]).first
		end
	end
	helpers SessionHelper
end

