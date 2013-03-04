#!/usr/local/bin/ruby -Ku
# Coding: utf-8

require "bundler/setup"

require "sinatra"
require 'sinatra/cross_origin'
require 'sinatra/formkeeper'
#require 'rack/csrf'
require 'logger'

require 'mongoid'
require_relative 'mongoidScheme'
#require_relative 'RhymeAuth'

#require 'redis'
require 'sinatra/redis'
#require 'rack/session/redis'

require "better_errors"

configure do
	logger = Logger.new("logs/access.log", "daily")
	logger.instance_eval {
		alias :write :'<<' unless respond_to?(:write)
	}
	use Rack::CommonLogger, logger

	#use Rack::Reloader, 5

	use Rack::Session::Cookie,
	#use Rack::Session::Redis,
		#:redis_server => "redis://127.0.0.1:6379/1",
		:key => 'noans.session',
		#:domain => '',
		#:path => '/',
		:expire_after => 60*60*24*7,
		:secret => 'fueefuee'

	use BetterErrors::Middleware
	BetterErrors.application_root = File.expand_path("..", __FILE__)
end

#require_relative "../lib/haml/link"
require_relative "../lib/sinatra/lib"

helpers do
  # def title
  #   if request.path_info == request.script_name #"/"
  #     return 	"真実はいつも解なし"
  #   else
  #     return "真実はいつも解なし - #{}"
  #   end
  # end
end

before do
	set :views, File.dirname(__FILE__) + '/views'
	set :redis, 'redis://127.0.0.1:6379/2'
	set :haml, :attr_wrapper => '"'
	set :haml, :format			 => :html5
	set :haml, :cdata				 => false
  @root_dir = request.script_name
end

get '/' do
	if logged_in?
		haml :index, locals: {path: "index"}
	else
		haml :login, locals: {path: "login"}
	end
end

get '/register/?' do
	haml :register, locals: {path: "register", title: "新規登録"}
end

before '/register/confirm/?' do
	check_csrf
end

post '/register/confirm/?' do
	form do
		field :name,			present: true
		field :id,				present: true, length: 4..255
		field :password,	present: true, length: 6..255
		field :email, 		email:	 true
	end

	duplicate_id = User.where(user: params[:id]).exists?

	if form.failed? || duplicate_id
		session[:form_error] = {}
		params.each do |key, value|
			session[:form_error][key.to_sym] = h(value)
		end
		session[:form_error][:duplicate_id] = duplicate_id
		session[:form_error][:redirect] = true
		redirect "#{@root_dir}/register/"
	else
		params.each {|k, v| params[k] = h(v)}
		params_copy = params.clone
		params_copy.default = nil
		session[:form_confirm] = params_copy.clone
		haml :register_confirm, locals: {path: "register_confirm", title: "新規登録"}
	end
end

post '/register/process/?' do
	halt 500 if session[:form_confirm].blank?
	data = session[:form_confirm]
	halt 500 if User.where(user: data[:id]).exists?
	user = User.new(name:			data["name"], user: data["id"],
					 				password: data["password"], mail: data["mail"])
	begin
		user.save!
	rescue
		halt 500
	end
	session[:form_confirm] = nil
	haml :register_completed, locals: {path: "register_completed", title: "登録完了"}
end

get '/login/?' do
	haml :login, locals: {path: "login", title: "ログイン"}
end

post '/login/?' do
	form do
		filters :strip
		field :id,		present: true
		field :password,	present: true
	end

	redirect_to "/login/" if form.failed?

	params.each {|k, v| params[k] = h(v)}

	db_user = User.where(user: params[:id])

	if db_user.empty? || db_user.first[:password] != params[:password]
		redirect_to "/login/"
	else
		session[:user_data] = db_user.first
		session[:user] = db_user.first[:user]
		redirect_to ?/
	end
end

get '/logout/?' do
	session[:user_data] = nil
	session[:user] = nil
	redirect_to ?/
end


get "/css/:file.css" do
	content_type :css
	send_file "./views/#{params[:file]}.css"
end

get '/:file.css' do
	content_type :css
	send_file "./views/#{params[:file]}.css"
end

get '/csrf/?' do
	raise Rack::Csrf::InvalidCsrfToken
end

load 'routes_admin.rb'
load 'routes_files.rb'
load 'routes_api.rb'
load 'routes_test.rb'
