#-*- coding : utf-8 -*-

require "bundler/setup"
require "sinatra"
require 'sinatra/formkeeper'
require 'rack/csrf'
require 'logger'

require 'mongoid'

require_relative 'mongoidScheme'
#require_relative 'RhymeAuth'

#require 'redis'
require 'sinatra/redis'
require 'rack/session/redis'

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
	use Rack::Csrf, :raise => true, :skip => ['POST:.*', 'PUT:.*', 'DELETE:.*']
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

	def logged_in?(admin = false)
		return !session[:user_data].nil? && session[:user_data][:admin] if admin
		!session[:user_data].nil?
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
	#@redis = Redis.new
	#Haml::Template.options[:attr_wrapper] = '"'
	set :haml, :attr_wrapper => '"'
	set :haml, :format			 => :html5
	@specific_object = nil
	@common_css = false

end

get '/' do
	@specific_object = :index
	haml :common #, :locals
end

get '/register/?' do
	@specific_object = :register
	@title = "新規登録"
	haml :common
end

before '/register/confirm/?' do
	check_csrf
end

post '/register/confirm/?' do
	form do
		filters :strip
		field :name,			:present => true
		field :id,				:present => true, :length => 4..255
		field :password,	:present => true, :length => 6..255
		field :email, 		:email	 => true
	end

	if form.failed?
		session[:form_error] = Hash::new
		params.each do |key, value|
			session[:form_error][key.to_sym] = h(value)
		end
		# ["name", "id", "email", "pass"].each do |key|
		# 	session[:form_error][key.to_sym] = params[key]
		# end
		session[:form_error][:redirect] = true
		redirect "#{request.script_name}/register/"
	else
		params.each {|k, v| params[k] = h(v)}
		params_copy = params.clone
		params_copy.default = nil
		session[:form_confirm] = params_copy.clone
		@specific_object = :register_confirm
		haml :common
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
	@specific_object = :register_completed
	haml :common
end

get '/login/?' do
	@specific_object = :login
	haml :common
end

get '/admin/?' do
	require_login(true)

	@specific_object = :admin
	haml :common
end

post '/login/?' do
	form do
		filters :strip
		field :id,		:present => true
		field :password,	:present => true
	end

	if form.failed?
		redirect "#{request.script_name}/login/"
	end

	params.each {|k, v| params[k] = h(v)}

	db_user = User.where(user: params[:id])

	redirect "#{request.script_name}/login/" if db_user.empty?

	if db_user.first[:password] == params[:password]
		# session[:login] = true
		# session[:id]		= db_user.first[:id]
		# session[:name]	= db_user.first[:name]
		session[:user_data] = db_user.first
		redirect "#{request.script_name}/"
	else
		redirect "#{request.script_name}/login/"
	end
	#@specific_object = :login
	#haml :common
end

get '/logout/?' do
	# session[:login] = nil
	# session[:id]		= nil
	# session[:name]	= nil
	session[:user_data] = []
	redirect "#{request.script_name}/"
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
	@specific_object = params[:obj].to_sym
	haml :common
end

get '/test/session/get/?' do
	session[:test]
end

get '/test/session/set/?' do
	session[:test] = "Sessioned! #{Time.now}"
	redirect '#{request.script_name}/session/get'
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

get '/test/md/:obj/?' do
	#markdown params[:obj].to_sym
	@specific_object = params[:obj].to_sym
	haml :MarkDownTemplate
end

__END__
@@MarkDownTemplate
!!!
%html
	%meta(charset = "utf-8")
	-#%style
	-#	:plain
	-#		h1 {color:blue;}
	%link(rel = "stylesheet" href = "#{request.script_name}/normalize.css")
	= markdown @specific_object
