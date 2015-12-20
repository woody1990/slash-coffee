require 'sinatra'
require 'sinatra/activerecord'
require './config/i18n'
require './config/environments'
require './app/commands'

post '/coffee' do
  content_type :json

  response = Commands.run_command(params)
  response.to_json
end

get '/authed' do
  I18n.t('auth.success')
end
