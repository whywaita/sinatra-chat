# encoding: utf-8

require 'sinatra'
require 'haml'
require 'csv'
require 'warden'

Encoding.default_external = "UTF-8"
enable :sessions

Warden::Strategies.add :login_test do
  def valid?
    params["name"] || params["password"]
  end

  def authenticate!
    if params != ""
      user = {
        :name => params["name"],
        :password => params["password"]
      }
      success!(user)
    else
      fail!("Could not login")
    end
  end
end

use Warden::Manager do |manager|
  manager.default_strategies :login_test

  manager.failure_app = Sinatra::Application
end

get "/" do
  if request.env["warden"].user.nil?
    haml :login
  else
    redirect "/bbs"
  end
end

post "/login" do
  request.env["warden"].authenticate!
  redirect "/bbs"
end

get "/logout" do
  request.env["warden"].logout
  redirect "/"
end

get '/bbs' do
  if request.env["warden"].user.nil?
    redirect "/"
  end

  @title = "sinatra chat"
  @text = "Hello haml"
  @bbs_data = CSV.read("resources/bbs_data.csv")

  haml :index
end

post '/bbs' do
  now = Time.now.to_s

  CSV.open("resources/bbs_data.csv", "a") do |f|
    f << [request.env["warden"].user[:name], params[:title], params[:message], now]
  end

  redirect "/bbs"
end

get '/user/:name' do |name|
  "hello, #{name}!"
end
