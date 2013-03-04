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

	field :text			,type: String
	field :showtop	,type: Boolean, default: false

	belongs_to :user
end

class Examination
	include Mongoid::Document

	field :grade	,type: Integer
	field :year		,type: Integer,	#Fiscal Year(年度)
			  default: -> { Time.now.month > 4 ? Time.now.year : Time.now.year - 1 }

	field :periodstart	,type: Date
	field :periodend		,type: Date

	field :type		,type: String	#Normal or Basic Science and Technology (BasicScience)

	field :count	,type: Integer
		# Normal:
		# 	1, 2 => 1学期
		#		3, 4 => 2学期
		#		5		 => 3学期
		#
		# BasicScience:
		#		1	=> 前期
		#		2	=> 後期
end

class ExamScore
	include Mongoid::Document
	include Mongoid::Timestamps

	field :subject	,type: String
	field :score		,type: Integer
end

class ExamAverage
	include Mongoid::Document

	field :targetaverage	,type: String,  default: "grade" #grade or grade-class (ex: 1-A)
end

class UploadImage
	include Mongoid::Document
	include Mongoid::Timestamps

	field :title		,type: String
	field :filetype	,type: String
	field :dir			,type: String
	field :filename	,type: String

end