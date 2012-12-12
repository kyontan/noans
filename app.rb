#!/usr/local/bin/ruby -Ku
# encoding: utf-8

#-*- coding : utf-8 -*-

require "bundler/setup"
require "sinatra"
require 'sinatra/cross_origin'
require 'sinatra/formkeeper'
require 'rack/csrf'
require 'logger'

require 'mongoid'
require_relative 'mongoidScheme'
#require_relative 'RhymeAuth'

#require 'redis'
require 'sinatra/redis'
require 'rack/session/redis'

require "better_errors"

configure do
	logger = Logger.new("logs/access.log", "daily")
	logger.instance_eval {
		alias :write :'<<' unless respond_to?(:write)
	}
	use Rack::CommonLogger, logger

	#enable :sessions
	#use Rack::Session::Cookie,
	use Rack::Session::Redis,
		:redis_server => "redis://127.0.0.1:6379/1",
		:key => 'rack.session',
		:domain => 'test.monora.me',
		:path => '/',
		:expire_after => 60*60*24*7,
		:secret => 'fueefuee'
	#use Rack::Csrf, :raise => true, :skip => ['POST:/register/process/?']
	use Rack::Csrf, raise: true, skip: ['POST:.*', 'PUT:.*', 'DELETE:.*']

	use BetterErrors::Middleware
	BetterErrors.application_root = File.expand_path("..", __FILE__)
end

helpers do
	def csrf_token
    Rack::Csrf.csrf_token(env)
  end

	def check_csrf
		unless params[Rack::Csrf.csrf_field] == session['csrf.token']
			raise Rack::Csrf::InvalidCsrfToken
		end
	end

	def blank?
		self.nil? || self.empty?
	end

	def logged_in?(admin = false)
		#session ||= {}
		ses =  !session[:user_data].blank?
		return ses && session[:user_data][:admin] if admin
		ses
	end

	def require_login(admin = false)
		halt 401 unless logged_in?(admin)
	end

	# def csrf_tag
 	# 	Rack::Csrf.csrf_tag(env)
 	# end

  alias_method :h, :escape_html
  # def title
  #   if request.path_info == request.script_name #"/"
  #     return 	"真実はいつも解なし"
  #   else
  #     return "真実はいつも解なし - #{}"
  #   end
  # end
  def blank?(input)
		input.nil? || input.empty?
  end
end

before do
	set :redis, 'redis://127.0.0.1:6379/2'
	#@redis = Redis.new(db: 2)
	set :haml, :attr_wrapper => '"'
	set :haml, :format			 => :html5
	set :haml, :cdata				 => false
	@specific_object = nil
	@common_css = false

  @root_dir = request.script_name
end

get '/' do
	#@specific_object = :index
	#begin
	# 	@text = redis.get("text")
	# rescue Exception => e
	# 	@text = e
	# end
	#@text = redis.get("text") #.to_s
	#haml :common, :layout => :index
	if logged_in?
		haml :index, locals: {path: "index"}
	else
		haml :login, locals: {path: "login"}
	end
end

get '/register/?' do
	@title = "新規登録"
	haml :register, locals: {path: "register"}
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
		haml :register_confirm, locals: {path: "register_confirm"}
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
	haml :register_completed, locals: {path: "register_completed"}
end

get '/login/?' do
	haml :login, locals: {path: "login"}
end

post '/login/?' do
	form do
		filters :strip
		field :id,		present: true
		field :password,	present: true
	end

	if form.failed?
		redirect "#{@root_dir}/login/"
	end

	params.each {|k, v| params[k] = h(v)}

	db_user = User.where(user: params[:id])

	redirect "#{@root_dir}/login/" if db_user.empty?

	if db_user.first[:password] == params[:password]
		# session[:login] = true
		# session[:id]		= db_user.first[:id]

		# session[:name]	= db_user.first[:name]
		session[:user_data] = db_user.first
		redirect "#{@root_dir}/"
	else
		redirect "#{@root_dir}/login/"
	end
end

get '/logout/?' do
	# session[:login] = nil
	# session[:id]		= nil
	# session[:name]	= nil
	session[:user_data] = nil
	redirect "#{@root_dir}/"
end

get '/admin/?' do
	require_login(true)

	haml :admin, locals: {path: "admin"}
end

post '/admin/set/post/?' do
	require_login(true)
	redirect "#{@root_dir}/admin/" if params[:post] == ""

	user = User.where(user: session[:user_data][:user]).first
	user.posts << Post.new(text: params[:post], showtop: true)

	redirect "#{@root_dir}/admin/"
end

post '/admin/set/text/?' do
	require_login(true)
	redirect "#{@root_dir}/admin/" if params[:text] == ""

	redis.set("text", params[:text])

	redirect "#{@root_dir}/admin/"
end

get "/css/:file.css" do
	content_type :css
	send_file "./views/#{params[:file]}.css"
end

get '/:file.css' do
	content_type :css
	send_file "./views/#{params[:file]}.css"
end

=begin
get '/get' do

	content_type :text, :charset => 'utf-8'
	#require 'pp'
	users = User.all
	#users.each do |obj|
	#pp obj.admin
	#end
	users[1][:user]
end

=end

load 'routes_api.rb'
load 'routes_error.rb'

get '/test' do
	haml :test
end

get '/test/error/:error_status' do
	halt params[:error_status].to_i
end

get '/test/render/:obj/?' do
	haml params[:obj].to_sym, locals: {path: params[:obj]}
end

get '/test/session/get/?' do
	session[:test]
end

get '/test/session/set/?' do
	session[:test] = "Sessioned! #{Time.now}"
	redirect '#{@root_dir}/session/get'
end

get '/test/session/clear/?' do
	session[:test] = nil
end

get '/test/post/?' do
	"Post"
end

#set :inline_template :true
before '/test/md/' do
	require 'rdiscount'
end

get '/test/raise/?' do
	raise "oops"
end

get '/test/reset/?' do
	require_login(true)

	system("touch ./tmp/restart.txt")

	redirect @root_dir if $?.exitstatus == 0
	"#{$?.exitstatus} <a href='#{@root_dir}'>back</a>"
end

get '/test/md/:obj/?' do
	#markdown params[:obj].to_sym
	haml :MarkDownTemplate, :layout => false, locals: {path: params[:obj].to_sym}
end

__END__
@@MarkDownTemplate
!!!
%html
	%meta(charset = "utf-8")
	-#%style
	-#	:plain
	-#		h1 {color:blue;}
	%link(rel = "stylesheet" href = "#{@root_dir}/normalize.css")
	= markdown @specific_object
