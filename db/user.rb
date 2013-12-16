# Coding: UTF-8

class User
	# require 'uuidtools'

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
  validates_length_of 			:user_name, min: 4, max: 12

  validates_length_of 			:password_confirm, min: 6, if: :new?
  validates_confirmation_of :password, confirm: :password_confirm, if: :new?

  validates_length_of 			:password_confirm, min: 6, when: :update_password
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
