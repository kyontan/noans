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
	posts = posts.where(created_at: Time.now-14.days..Time.now) if params[:num].nil?
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
