# Coding: UTF-8

class LoggedActivity
	include DataMapper::Resource

	property :id, 			Serial
	property :type,			String

	belongs_to :user

	# DM-Timestamps
	property :created_at,	DateTime

	validates_presence_of :type
end


