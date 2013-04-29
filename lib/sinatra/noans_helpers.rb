#!/usr/local/bin/ruby

require 'sinatra/base'

module Sinatra
	module NoansHelpers
		def logged_in?(admin = false)
			ses = !user_data.nil?
			return admin ? (ses && user_data.admin) : ses
		end

		def require_login(admin = false)
			halt 401 unless logged_in?(admin)
		end
	end
	helpers NoansHelpers

	module SessionHelper
		def user_data
			User.where(id: session[:id]).first
		end
	end
	helpers SessionHelper
end

