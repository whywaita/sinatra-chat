# encoding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'csv'

Encoding.default_external = "UTF-8"

get '/' do
  @title = "sinatra chat"
  @text = "Hello haml"
  @bbs_data = CSV.read("resources/bbs_data.csv")
  haml :index
end

post '/' do
  CSV.open("resources/bbs_data.csv", "a") do |f|
    f << [params[:name], params[:title], params[:message]]
  end

  redirect to('/')
end

get '/user/:name' do |name|
  "hello, #{name}!"
end

