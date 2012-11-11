#-*- coding : utf-8 -*-

#$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.push(File.dirname(__FILE__))

require "bundler/setup"
require "sinatra"
require 'sinatra/formkeeper'
require 'RhymeAuth'
require 'cgi'

require 'mongoid'
require './mongoidScheme.rb'

require 'redis'
require 'logger'

#enable :sessions
use Rack::Session::Cookie,
	:key => 'rack.session',
	:domain => 'test.monora.me',
	:path => '/',
	:expire_after => 60*60*24*7,
	:secret => 'fueefuee'


configure do
	logger = Logger.new("logs/access.log", "daily")
	logger.instance_eval {
		alias :write :'<<' unless respond_to?(:write)
	}
	use Rack::CommonLogger, logger

end

before do
	@redis = Redis.new
	#Haml::Template.options[:attr_wrapper] = '"'
	set :haml, :attr_wrapper => '"'
	set :haml, :format			 => :html5
	@specific_object = nil
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

post '/register/confirm/?' do

	# if params[:name].nil? ||
	# 	 params[:pass].nil? || params[:pass].length < 6 ||
	# 	 params[:id].nil? 	|| params[:id].length < 4 then
	# 	 	session[:form_error] = Hash::new
	# 		["name", "id", "email", "pass"].each do |key|
	# 			session[:form_error][key.to_sym] = params[key]
	# 		end
	# 		session[:form_error][:redirect] = true

	# 		redirect "#{request.script_name}/register/"
	# end
	form do
		filters :strip
		field :name,	:present => true
		field :pass,	:present => true, :length => 6..32
		field :email, :email	 => true
		field :id,		:present => true, :length => 4..32
	end

	if form.failed?
		session[:form_error] = Hash::new
		["name", "id", "email", "pass"].each do |key|
			session[:form_error][key.to_sym] = params[key]
		end
		session[:form_error][:redirect] = true
		redirect "#{request.script_name}/register/"
	else
		params_temp = params.clone
		params_temp.default = nil
		session[:form_confirm] = Marshal.load(Marshal.dump(params_temp))

		@specific_object = :register_confirm
		haml :common
	end
end

post '/register/process/?' do
	halt 418 if session[:form_confirm].empty?

	@form_value = Hash::new
	session[:form_confirm].each do |key , value|
		@form_value[key.to_sym] = CGI.escapeHTML(value)
	end

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