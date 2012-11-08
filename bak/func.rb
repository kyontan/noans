require 'time'
require 'json'
require 'twitter'

require 'redis'
@redis = Redis.new(:host => "127.0.0.1", :port => 6379)

require 'cgi'
require 'cgi/session'
@cgi = CGI.new
#@cgi.params.merge!(CGI::parse(@cgi.query_string)){|key, self_val, other_val| self_val }

=begin
require 'mongo_mapper'
MongoMapper.connection = Mongo::Connection.new('localhost')
load 'mongoScheme.rb'
=end

#----------------------------------------

def login(user,pass)

	id = @redis.HGET("user", user)
	
	return 0 if id == nil
	
	pass_redis = @redis.HGET("pass", id)
	
	if pass == pass_redis then
		db = {:time => Time.now, :user => user, :login => true }
		@redis.LPUSH("login", db.to_json)
		return 1
	else
		dbin = {:time => Time.now, :user => user, :login => false }
		@redis.LPUSH("login", db.to_json)
		return 0
	end
end

#def user_new(user, id, pass)
def user_new_hst(user, id, pass, mail = nil, name = nil) 
	
	
end 

=begin
def user_new(user, id, pass)
  #return 0 user.nil? || id.nil? || pass.nil?
  return 0 if (id.to_s =~ /^[+-]?\d+$/) == nil
  
  ret = @redis.HSETNX("user", user, id)
  
  return -1 if ret == 0
  
  ret = @redis.HSETNX("pass", id, pass)
  
  return -1 if ret == 0
  
  return 1
end

def user_new_hst(user, id, pass, mail = nil, name) 
  #return 0 if (id.to_s =~ /^[+-]?\d+$/) == nil
  
  ret = @redis.HEXISTS("user", user)
  
  return 0 if ret == 1
  
  ret = user_new(user, id, pass)
  
  return 0 if ret == 0 || ret == -1
  @redis.HSET("mail", id, mail)
  @redis.HSET("name", id, name)
  
  return 1
  
end
=end



def post_text(user,text,twitter = 0)
	return if text == ''
	
	postdata = {:user => user, :type => "text", :data => text, :time => Time.now}
	
	@redis.LPUSH("post", postdata.to_json)

	if twitter == 1 then
		Twitter.configure do |config|
			config.consumer_key = 'B3DCjxJ9llDChPs6tKQ7A'
			config.consumer_secret = '29PELP2wf4dwlKbYbNASrFyIJiQk07IFZKQeOhuYjo'
			config.oauth_token = '589188974-ZsTc4NOg1ZEg8NIeFvYdVkyrMtVYrvJjp4IhEHLF'
			config.oauth_token_secret = 'bYs6ILBPHhNt3l8jcRTVG3BwTO97q1e5zQLCpLJqxw'
		end
		
		Twitter.update(text)
	end
	
end

def post_get(n = 10, hidden = 0)
	n = 10 if n == nil || n == ""
	postget = @redis.LRANGE("post", 0, n)
	return postget
end

def session_load()
	session_exp = Time.now + 60*60*24*7
	begin
		@session = CGI::Session.new(@cgi, {"new_session"=>false, "tmpdir" => "../session/", "session_expires" => session_exp})
	rescue ArgumentError
	  @session = CGI::Session.new(@cgi, {"new_session"=>true, "tmpdir" => "../session/", "session_expires" => session_exp})
	end
end

def sessionid()
	return @session.session_id
end

def getParam(param = "")
	return CGI.escapeHTML(@cgi[param])
end

def isLogin(user = '')
	if user != "" then
		return true if @session["login"] == user 
	else
		return true if @session["login"] != nil
	end
	return false
end
