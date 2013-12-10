require "logger"
require "bundler"

require 'fileutils'
FileUtils.makedirs(["uploads", "log"])

Bundler.require

set :environment, :development
# set :environment, :production

Bundler.require(settings.environment)

require File.expand_path(File.dirname(__FILE__)) + '/app.rb'

run Sinatra::Application
