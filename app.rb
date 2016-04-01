require 'sinatra'
require 'sinatra/activerecord'
require 'net/http'
require './config/i18n'
require './config/environments'
require './app/commands'

get '/coffee' do
  content_type :json

  Commands.execute(params).to_json
end

get '/authed' do
  uri = URI('https://slack.com/api/oauth.access')
  uri_params = {client_id: ENV['SLACK_CLIENT_ID'], client_secret: ENV['SLACK_CLIENT_SECRET'], code: params['code']}
  uri.query = URI.encode_www_form(uri_params)
  Net::HTTP.get_response(uri)

  redirect 'http://coffee.agelber.com/authed/'
end
