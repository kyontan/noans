require 'sinatra/base'

module Sinatra
	module Auth

		require 'redis'
		require 'json'
		#@redis = Redis.new
		#@redis_db = "auth_test"
		#@redis.set(redis_db,[].to_json)
		@nowlogin = "nowlogin.json" 
		File.write(@nowlogin, [].to_json)

		def require_login # before filter
			halt 301 unless logged_in?
		end

		#ここから
		def login(username,password,remember_me = false)
			
			
			setSession("user", user)
			#setSession("remember", remember_me)
			remember_me ? remember_me! : forget_me!
		end

		def auto_login(user)# 認証情報無しでログイン
			setSession("user", user)
		end
		#ここまで


		def logout
			# File.read(@nowlogin) do |r|
			# 	loginlist			
			# end
			
			File.save(@nowlogin, current_users.reject{|t| t == current_user})
			#@redis.set(redis_db, current_users.reject{|t| t == current_user)
			setSession("user", nil)
		end

		def logged_in?
			getSession("user") != false
		end

		def current_user
			getSession("user")
		end

		#redirect_back_or_to # ログイン後にユーザーが最初にアクセスしようとしていたページにリダイレクトさせたいときに使用する

		#@user.external? # facebook/twitter などの外部ユーザーであることを表すために使用する
		#User.authenticates_with_sorcery!

		def current_users
			File.read(@nowlogin) do |r|
				return JSON.parse(r)
			end
		end
		# http basic auth
		#require_login_from_http_basic # before filter

		# external
		#login_at(provider) # ユーザーを認証のために外部プロバイダ(twitter など)に飛ばす
		#login_from(provider) # 外部プロバイダのコールバックを元にログインを試みる
		#create_from(provider) # ローカルDBにユーザーを作成する

		def auto_login(user, should_remember=false)  # remember_me オプション付きで auto_login
			auto_login(user)
			setSession("remember", true) if should_remember
		end

		def remember_me!
			setSession("remember", true)
		end

		def forget_me!
			setSession("remember", false)
		end

		def getSession(key)
			return false if session[key.to_sym].nil?
			session[key.to_sym]
		end

		def setSession(key, value)
			session[key.to_sym] = value
		end

		# reset password
		#User.load_from_reset_password_token(token)
		#@user.deliver_reset_password_instructions!
		#@user.change_password!(new_password)

		# user activation
		#User.load_from_activation_token(token)
		#@user.activate!
	end
	helpers Auth
	#register Auth
end