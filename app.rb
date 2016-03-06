require 'sinatra'
require 'sinatra/activerecord'
require 'net/http'
require './config/i18n'
require './config/environments'
require './app/commands'

post '/coffee' do
  content_type :json

  response = Commands.run_command(params)
  response.to_json
end

get '/authed' do
  uri = URI('https://slack.com/api/oauth.access')
  params = {client_id: ENV['SLACK_CLIENT_ID'], client_secret: ENV['SLACK_CLIENT_SECRET'], code: params['code']}
  uri.query = URI.encode_www_form(params)
  Net::HTTP.get_response(uri)

  I18n.t('auth.success')
end
