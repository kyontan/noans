require File.expand_path(File.dirname(__FILE__)) + '/app'

set :environment, :development
run Sinatra::Application
