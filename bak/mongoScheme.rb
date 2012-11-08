MongoMapper.database = 'user'

class User
	include MongoMapper::Document
	key	:name,			String #名前
	key	:user, 			String, :required => true #ログインID
	key :password,String, :required => true #パスワード
	
	key :studentid	,Integer #学籍番号
	
	key	:admin,		Boolean, :default => false

	timestamps!
		
	many:login
end
#User.ensure_index(:name)

class Login
	include MongoMapper::EmbeddedDocument
  key :time, Time			, :required => true #ログイン時刻
  
  belongs_to :user
end

class Comment
	include MongoMapper::Document
  key :comment, String, :required => true #コメント内容
  key	:time		,	Time	,	:required => true #書き込み時刻
  
  belongs_to :user
end