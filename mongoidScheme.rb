Mongoid.load!('mongoid.yml', :development)

class User
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paranoia

  field :display_name	,type: String
  field :user_id    	,type: String

  #password = 1024.times{ original_pass = Digest::SHA256.hexdigest(original_pass + salt) }
  field :password			,type: String
  field :salt					,type: String

  field :mail     	 	,type: String

  #field :studentid ,type: Integer
  field :admin     		,type: Boolean, default: false

	has_many :posts
	has_many :fileGroups
	has_many :loggedActivities
end

class Post
	include Mongoid::Document
	include Mongoid::Timestamps

	field :text			,type: String
	field :showtop	,type: Boolean, default: false

	belongs_to :user
end

#Log in, Log out history
class LoggedActivity
	include Mongoid::Document
	include Mongoid::Timestamps

	field :type	,type: String # "login" || "logout"
	field :ip		,type: String

	belongs_to :user
end

# class Examination
# 	include Mongoid::Document

# 	field :grade	,type: Integer
# 	field :year		,type: Integer,	#Fiscal Year(年度)
# 			  default: -> { Time.now.month > 4 ? Time.now.year : Time.now.year - 1 }

# 	field :periodstart	,type: Date
# 	field :periodend		,type: Date

# 	field :type		,type: String	#Normal or Basic Science and Technology (BasicScience)

# 	field :count	,type: Integer
# 		# Normal:
# 		# 	1, 2 => 1学期
# 		#		3, 4 => 2学期
# 		#		5		 => 3学期
# 		#
# 		# BasicScience:
# 		#		1	=> 前期
# 		#		2	=> 後期
# end

# class ExamScore
# 	include Mongoid::Document
# 	include Mongoid::Timestamps

# 	field :subject	,type: String
# 	field :score		,type: Integer
# end

# class ExamAverage
# 	include Mongoid::Document

# 	field :targetaverage	,type: String,  default: "grade" #grade or grade-class (ex: 1-A)
# end

class FileGroup
	include Mongoid::Document
	include Mongoid::Timestamps

	field :title			, type: String
	field :folder_name, type: String

	belongs_to :user
	embeds_many :uploadedFiles
end

class UploadedFile
	include Mongoid::Document
	include Mongoid::Timestamps

	field :type, 			type: String
	field :file_name, type: String
	field :saved_path, 			type: String

	field :access_count, type: Integer, default: 0

	embedded_in :fileGroup
end
