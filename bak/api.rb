#!/usr/local/bin/ruby -Ku
# encoding: UTF-8

load './func.rb'

status = Hash::new

session_load


#puts @cgi.header({ 'Content-Type' => 'text/plain', 'charset' => 'UTF-8'})
print "Access-Control-Allow-Origin: *\n"
print "Content-Type: text/html; charset=utf-8;\n\n"
#puts @cgi.header({ 'Content-Type' => 'application/json', 'charset' => 'UTF-8'})

if @session["login"] == nil then
 print "error No Login"
 	exit
end


if getParam("mode") == "getpost" then
	write = ""
	write += '['
	
	num = getParam("num") == "" ? nil : getParam("num")
	
	begin
		post_get(num).each do |post|
			write += post
			write += ','
		end
	
		write = write.chop
		write += ']'
	
		print write
	rescue
		print "Take a negative number argument can not be."
	end
	exit
end

if getParam("mode") == "gettext" then
	print @redis.GET("karitext")
	exit
end

print "Unspecified Error"
