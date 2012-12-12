Mongoid.load!('mongoid.yml', :development)

class User
	include Mongoid::Document
	include Mongoid::Timestamps

  field :name       ,type: String
  field :user       ,type: String
  field :password		,type: String

  field :mail      	,type: String

  #field :studentid ,type: Integer
  field :admin      ,type: Boolean, default: false

	has_many :posts
end

class Post
	include Mongoid::Document
	include Mongoid::Timestamps

	field :text			, type: String
	field :showtop	, type: Boolean, default: false

	belongs_to :user
end