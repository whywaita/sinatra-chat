# encoding: utf-8

require 'sinatra'
require 'faml'
require 'csv'
require 'warden'
require 'securerandom'
require 'digest/sha2'

redis = Redis.new host:"redis", port:"6379"

configure do
  enable :sessions
  Encoding.default_external = "UTF-8"
end


Warden::Strategies.add :login_test do
  def valid?
    params["name"] || params["password"]
  end

  def authenticate!
    if params["name"] != ""
      user = {
        :name => params["name"],
        :password => params["password"]
      }
      token = SecureRandom.hex(20)
      phrase = params["name"] + token
      h = Digest::SHA256.hexdigest phrase
      redis.set("session", h)

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

post "/unauthenticated" do
  haml :fail_login
end

get '/bbs' do
  if request.env["warden"].user.nil?
    redirect "/"
  end

  @title = "Sinatra chat"
  @bbs_data = CSV.read("resources/bbs_data.csv")

  haml :index
end

post '/bbs' do
  now = Time.now.to_s
  if params[:message] == ""
    redirect "/bbs"
  end

  CSV.open("resources/bbs_data.csv", "a") do |f|
    f << [request.env["warden"].user[:name], params[:message], now]
  end

  redirect "/bbs"
end
