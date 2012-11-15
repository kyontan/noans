#-*- coding : utf-8 -*-

#$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.push(File.dirname(__FILE__))

require "bundler/setup"
require "sinatra"
require 'sinatra/formkeeper'
require 'rack/csrf'
require 'logger'

require 'mongoid'
require 'mongoidScheme'
require 'RhymeAuth'

require 'redis'

configure do
	logger = Logger.new("logs/access.log", "daily")
	logger.instance_eval {
		alias :write :'<<' unless respond_to?(:write)
	}
	use Rack::CommonLogger, logger
	#enable :sessions
	use Rack::Session::Cookie,
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
	rescue
		false
  end
end

before do
	@redis = Redis.new
	#Haml::Template.options[:attr_wrapper] = '"'
	set :haml, :attr_wrapper => '"'
	set :haml, :format			 => :html5
	@specific_object = nil
	@common_css = false
end

get '/' do
	@specific_object = :index
	haml :common
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
		field :name,	:present => true
		field :id,		:present => true, :length => 4..32
		field :pass,	:present => true, :length => 6..32
		field :email, :email	 => true
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
	halt 418 if session[:form_confirm].blank?
	data = session[:form_confirm]
	halt 418 unless blank? User.where(user: data[:id]).to_a.first
	user = User.new(name:			data["name"], user: data["id"],
					 				password: data["pass"], mail: data["mail"])
	begin
		user.save!
	rescue
		halt 418
	end
	session[:form_confirm] = nil
	@specific_object = :register_completed
	haml :common
end

get '/login/?' do
	@specific_object = :login
	haml :common
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
