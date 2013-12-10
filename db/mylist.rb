# Coding: UTF-8

class Mylist
	include DataMapper::Resource

	property :id, 			Serial

	property :title,		String
	property :comment,	Text,			lazy: false

	property :access_count,			Integer, default: 0
	property :public,						Boolean, default: true
	property :deleted,					Boolean, default: false
	property :others_can_edit, 	Boolean, default: false

	validates_presence_of :title
	validates_uniqueness_of :title

	belongs_to :user
	has n, :uploaded_files, through: Resource

	# DM-Timestamps
	property :created_at,	DateTime
	property :updated_at,	DateTime

	def self.key_translation
		{
			"id" 			=> "ID",
			"title"		=> "タイトル",
			"comment"	=> "コメント",
			"access_count"	=> "アクセス数",
			"public"	=> "公開ステータス",
			"deleted"	=> "削除済みフラグ"
		}
	end

	def self.public
		self.available.all(public: true)
	end

	def self.available
		self.all(deleted: false)
	end

end