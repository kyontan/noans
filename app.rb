#!/usr/local/bin/ruby
# Coding: UTF-8

require "bundler/setup"

require "sinatra"
require "sinatra/cross_origin"
require "sinatra/formkeeper"
#require "rack/csrf"
require "logger"

require "haml"
require "sass"
require "rdiscount"

require "mongoid"
require_relative "mongoidScheme"
#require_relative "RhymeAuth"

#require "redis"
#require "sinatra/redis"
require "redis-sinatra"

require "better_errors"
# require "sinatra/reloader" if development?
# configure :development do
#   use Rack::Reloader
# end

configure do
	logger = Logger.new("logs/access.log", "daily")
	logger.instance_eval { alias :write :<< unless respond_to?(:write) }
	use Rack::CommonLogger, logger

	use Rack::Session::Cookie,
		key: 'noans.session',
		#domain: '',
		#path: '/',
		expire_after: 60 * 60 * 24 * 7, # 7 days
		secret: 'fueefuee'

	#set :views, settings.root + '/views'
	set :redis, 'redis://127.0.0.1:6379/2'
	set :haml, attr_wrapper: ?"
	set :haml, format: :html5
	set :haml, cdata: false
	set :scss, style: :expanded
end

configure :development do
	use BetterErrors::Middleware
	BetterErrors.application_root = settings.root
end

$LOAD_PATH.unshift "./lib/"
require 'sinatra/noans_helpers'
require 'sinatra/usual_helpers'
require 'sinatra/error_routes'
require 'haml/link_helpers'
# class Object
# 	def blank?
# 		self.nil? || self.empty?
# 	end
# end

helpers Sinatra::NoansHelpers
helpers do
  # def title
  #   if request.path_info == request.script_name #"/"
  #     return 	"真実はいつも解なし"
  #   else
  #     return "真実はいつも解なし - #{}"
  #   end
  # end

	def check_csrf; end

	def csrf_token; end

  def password_hash(password, salt = nil)
  	require 'securerandom'
  	require 'digest/sha2'
  	salt ||= SecureRandom.urlsafe_base64(24)
  	p = password
  	1024.times{ p = Digest::SHA256.hexdigest(p + salt) }
  	[p, salt]
  end

  alias_method :h, :escape_html
end

before do
  #@root_dir = request.script_name
  redis.set("text", "") 				if redis.get("text").nil?
  redis.set("access_count", 0)	if redis.get("access_count").nil?
end

get '/' do
	if logged_in?
		haml :index, locals: {path: "index"}
	else
		haml :login, locals: {path: "login"}
	end
end

load 'routes_user-activity.rb'
load 'routes_admin.rb'
load 'routes_files.rb'
load 'routes_api.rb'
load 'routes_test.rb'
