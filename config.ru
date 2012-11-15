require File.expand_path(File.dirname(__FILE__)) + '/app'

#set :environment, :production
set :environment, :development
run Sinatra::Application
