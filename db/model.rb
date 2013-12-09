# Coding: UTF-8

class User
	require 'uuidtools'

	include DataMapper::Resource

	property :user_name,	Slug,			key: true
	property :admin,			Boolean,	default: false

	property :password,		BCryptHash
	attr_accessor :password_confirm

	property :mail,				String

	property :draft,			Boolean,	default: true
	property :deleted,		Boolean,	default: false

	property :uuid,				UUID,			default: UUIDTools::UUID.random_create, writer: :private

	validates_presence_of 	:user_name, :password
  validates_uniqueness_of :user_name, :mail, :uuid

  validates_length_of 			:user_name, min: 4

  validates_length_of 			:password_confirm, min: 6, if: :new?
  validates_confirmation_of :password, confirm: :password_confirm, if: :new?
	validates_confirmation_of :password, confirm: :password_confirm, when: :update_password

	validates_format_of :mail, as: :email_address

	before :update do
		self.uuid = SecureRandom.uuid
	end

	has n, :mylists
  has n, :uploaded_files
  has n, :logged_activities

	# DM-Timestamps
	property :created_at,	DateTime
	property :updated_at,	DateTime

	def self.available
		all(draft: false, deleted: false)
	end

	def available?
		self.draft == false && self.deleted == false
	end

	def self.key_translation
		{
			"User name" 	=> "ユーザ名",
			"admin"				=> "管理者フラグ",
			"password"		=> "パスワード",
			"Password confirm"	=> "パスワード",
			"mail"				=> "メールアドレス",
			"deleted"			=> "削除済みフラグ"
		}
	end
end


class LoggedActivity
	include DataMapper::Resource

	property :id, 			Serial
	property :type,			String

	belongs_to :user

	# DM-Timestamps
	property :created_at,	DateTime

	validates_presence_of :type
end


class Mylist
	include DataMapper::Resource

	property :id, 			Serial

	property :title,		String
	property :comment,	Text,			lazy: false

	property :access_count,		Integer,	default: 0
	property :public,		Boolean,	default: true
	property :deleted,	Boolean,	default: false

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
		self.all(public: true, deleted: false)
	end

	def self.available
		self.all(deleted: false)
	end

end


class UploadedFile
	include DataMapper::Resource

	property :id, 						Serial

	property :orig_file_name,	String
	property :file_type,			String
	property :file_size,			Integer
	property :access_count,		Integer,	default: 0

	property :public,		Boolean,	default: true
	property :uploaded,	Boolean,	default: false
	property :deleted,	Boolean,	default: false

	validates_presence_of :file_size

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
		self.all(public: true, deleted: false)
	end

	def self.available
		self.all(deleted: false)
	end
end