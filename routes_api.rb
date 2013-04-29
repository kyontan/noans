#-*- Coding:UTF-8 -*-

before '/api/*' do
	require 'json'
	require 'time'

	cross_origin
	require_login
end

get '/api/text/?' do
	redis.get("text")
end

get '/api/post/?:num?/?' do
	num = 10
	num = params[:num].to_i unless params[:num].to_i.zero?
	num = 0 if params[:num] == "all"
	posts = Post.where(showtop: true)
	posts = posts.where(created_at: Time.now - 14.days..Time.now) if params[:num].nil?
	posts = posts.limit(num).to_a
	posts.each_with_object([]) do |l, h|
		post = {
			name: l.user[:name],
			text: l[:text],
			time: l[:created_at].localtime.strftime("%y/%m/%d %R")
		}
		h << post
	end.to_json
end

get '/api/access_count/?' do
	#unless env["REMOTE_ADDR"] == env["SERVER_ADDR"]

	db_name_count = "access_count"
	db_name_hash 	= "access_count_ip_hash"

	redis.hgetall(db_name_hash).each do |ip, time|
		redis.hdel(db_name_hash, ip) if Time.now - Time.parse(time) >= 3600
	end

	# Time to allow duplication count
	distance = 60 * 60 #[sec]
	log = redis.hget(db_name_hash, request.ip)


	if log.nil? || Time.now - Time.parse(log) >= distance
		redis.hset(db_name_hash, request.ip, Time.now)
		redis.incr(db_name_count)
	end

	redis.get(db_name_count).to_json
end