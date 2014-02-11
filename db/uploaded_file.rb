# Coding: UTF-8

class UploadedFile
	include DataMapper::Resource

	property :id, 						Serial

	property :orig_file_name,	String, length: 255
	property :file_type,			String
	property :file_size,			Integer
	property :access_count,		Integer, default: 0

	property :sha2,						String, length: 64

	property :public,		Boolean,	default: true
	property :uploaded,	Boolean,	default: false
	property :deleted,	Boolean,	default: false

	validates_presence_of :file_size

	validates_presence_of 	:sha2

	validates_presence_of 	:orig_file_name
  validates_length_of 		:orig_file_name, min: 1, max: 255

	belongs_to :user
	has n, :mylists, through: Resource

	# DM-Timestamps
	property :created_at,		DateTime

	def file_name
		"#{id}_#{orig_file_name}"
	end

	def self.key_translation
		{
			"id" 						=> "ID",
			"file_name"			=> "ファイル名",
			"file_type"			=> "ファイルの種類",
			"file_size"			=> "ファイルサイズ",
			"access_count"	=> "アクセス数",
			"deleted"				=> "削除済みフラグ"
		}
	end

	def self.public
		self.available.all(public: true)
	end

	def self.available
		self.all(deleted: false, uploaded: true)
	end
end
