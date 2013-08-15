require File.expand_path(File.dirname(__FILE__)) + '/app.rb'

set :environment, :production
#set :environment, :development
run Sinatra::Application
