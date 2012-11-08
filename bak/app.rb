require 'sinatra'

require 'mongo_mapper'
require './mongoScheme.rb'

load './func.rb'

configure do
	MongoMapper.database = "NoAns_dev"
end

status = Hash::new
session_load

#status["login"] = @session["login"]
#status["mode"] = CGI.escapeHTML(@cgi["mode"])

get '/' do
	"No Login."
end

get '/post' do
	user = User.new
	user.user = params[:user]
	user.password = params[:pass]
	user.studentid = params[:id] if params[:id] != ""
	user.save
	"Saved"
end

get '/get' do

	content_type :text, :charset => 'utf-8'
	require 'pp'
	users = User.all
	#users.each do |obj|
	#pp obj.admin
	#end
	users[1][:user]
end
