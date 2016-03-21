# encoding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'csv'

Encoding.default_external = "UTF-8"

get '/' do
  @title = "Hello world!"
  @text = "Hello haml"
  @bbs_data = CSV.read("resources/bbs_data.csv")
  haml :index
end

put '/request_print' do
  @request_method = request.request_method
  @request_url = request.url
  @request_path = request.path

  @name = params[:name]
  @title = params[:title]
  @messeage = params[:messeage]

  redirect to('/login/' + params[:name])
end

get '/login/:name' do |name|
  "hello, #{name}!"
end

