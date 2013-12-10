#!/usr/local/bin/ruby
# Coding: UTF-8

require_relative "db/model"

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/#{settings.environment}.sqlite3")
# DataMapper.setup(:default, 'sqlite::memory:')

DataMapper::Validations::I18n.localize! "ja"
DataMapper.finalize
DataMapper.auto_upgrade!

configure :development do
	use BetterErrors::Middleware
	BetterErrors.application_root = settings.root
end

configure do
	log_path = Pathname(settings.root) + "log"
	FileUtils.makedirs(log_path)
	logger = Logger.new("#{log_path}/#{settings.environment}.log", "daily")
	logger.instance_eval { alias :write :<< unless respond_to?(:write) }
	use Rack::CommonLogger, logger

	use Rack::Session::Cookie,
		key: 'noans.session',
		secret: 'fueefuee',
		# domain: '',
		path: '/',
		expire_after: 60 * 60 * 24 * 180 # 3 months

	use Rack::Protection::RemoteToken
	use Rack::Protection::SessionHijacking
	use Rack::Csrf, raise: true

	enable :prefixed_redirects
	set :haml, attr_wrapper: ?"
	set :haml, format: :html5
	set :haml, cdata: false
	set :scss, style: :expanded
end

$LOAD_PATH.unshift "./lib/"
require 'sinatra/usual_helpers'
require 'sinatra/error_routes'
require 'haml/link_helpers'

helpers do
	class ::Hash
		def select_keys(*key)
			key.inject({}){|h, k| h[k] = self[k]; h}
		end
	end

	def flat_map2(val, &block)
		if val.is_a? Hash
			val.each_with_object({}) {|(k, v), h| h[k] = flat_map2(v, &block)}
		elsif val.is_a? Array
			val.map{|v| flat_map2(v, &block) }
		else
			yield val
		end
	end

	def dic_sub(str, dic)
		ret = str.clone
		dic.each{|s, ss| ret.gsub!(s, ss) }
		ret
	end

  # def params_filled?(required)
  # 	required.all?{|r| !request.params[r.to_s].nil? }
  # end

  # def get_mime_type(file_path)
		# type = MIME::Types.type_for("")[0]
		# return type && type.simplified
  # end

  def user_data(user_name = session[:user_name])
  	User.first(user_name: user_name)
  end

  def logged_in?(isadmin = false)
  	!user_data.nil? && !user_data.draft && !user_data.deleted && (!isadmin || user_data.admin)
  end

  def login!(user_name, password)
  	user_name, password = h(user_name), h(password)
  	if (user = user_data(user_name)) && user.available? && (user.password == password)
  		session[:user_name] = user_name
  		LoggedActivity.create(user: user_data, type: "login")
  		true
  	else
  		false
  	end
  end

  def logout!
 		LoggedActivity.create(user: user_data, type: "logout")
  	session.delete(:user_name)
  end

  def require_login(isadmin = false)
  	redirect "/login" unless logged_in?
  	halt 401 unless logged_in?(isadmin)
  end

  alias_method :h, :escape_html
end

before do
end

get '/' do
	if logged_in?
		haml :index, locals: {path: "index"}
	else
		haml :login, locals: {path: "login"}
	end
end

require_relative 'routes/user-activity'
# require_relative 'routes/admin'
require_relative 'routes/assets'
# require_relative 'routes/api'
require_relative 'routes/dev'
require_relative 'routes/file'
require_relative 'routes/mylist'
require_relative 'routes/search'
require_relative 'routes/upload'
require_relative 'routes/user'