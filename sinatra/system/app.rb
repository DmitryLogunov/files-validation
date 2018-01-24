require "sinatra"
require "sinatra/activerecord"

ROOT_PATH = File.expand_path("../../", __FILE__)
configure do
  set :root, ROOT_PATH
  set :views, File.join(ROOT_PATH, 'app/views')
  set :database_file, File.join(ROOT_PATH, 'config/database.yml')
end

get '/' do
  erb :'index.html'
end
