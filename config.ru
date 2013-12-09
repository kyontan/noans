require "logger"
require "bundler"

Bundler.require

set :environment, :development
# set :environment, :production

Bundler.require(settings.environment)

require File.expand_path(File.dirname(__FILE__)) + '/app.rb'

run Sinatra::Application
