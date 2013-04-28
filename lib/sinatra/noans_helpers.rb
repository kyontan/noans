#!/usr/local/bin/ruby

require 'sinatra/base'

module Sinatra
	module NoansHelpers
		def logged_in?(admin = false)
			ses = !userData.nil?
			return admin ? (ses && userData.admin) : ses
		end

		def require_login(admin = false)
			halt 401 unless logged_in?(admin)
		end
	end
	helpers NoansHelpers

	module SessionHelper
		def userData
			User.where(id: session[:id]).first
		end
	end
	helpers SessionHelper
end

