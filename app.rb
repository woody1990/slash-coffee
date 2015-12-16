require 'sinatra'
require 'sinatra/activerecord'
require './config/i18n'
require './models/run'
require './models/order'
require './config/environments'

post '/coffee' do
  content_type :json

  args = params['text'].split
  response = case args.first
  when 'run' then start(args[1], params)
  when 'order' then order(params['user_name'], args[1..-1].join(' '), params)
  when 'list' then list(params)
  when 'here' then here(params)
  else help
  end
  response.to_json
end

def start(time, params)
  if run = current_channel_run(params)
    respond I18n.t('start.already_on_run', name: run.runner)
  else
    if time.nil?
      respond I18n.t('start.time_missing')
    else
      run = Run.create(
        team_id: params['team_id'], 
        channel_id: params['channel_id'], 
        user_id: params['user_id'],
        runner: params['user_name'],
        time: time)
      respond_in_channel I18n.t('start.success', name: run.runner, time: time)
    end
  end
end

def order(user, item, params)
  if run = current_channel_run(params)
    if item.nil?
      respond I18n.t('order.order_missing', name: run.runner)
    else
      run.orders.create(orderer: user, item: item)
      respond I18n.t('order.success', item: item)
    end
  else
    respond I18n.t('order.no_run')
  end
end

def list(params)
  if run = current_channel_run(params)
    if run.orders.empty?
      respond I18n.t('list.no_orders')
    else
      list = [I18n.t('list.success_header')]
      run.orders.each_with_index do |order, index|
        list << I18n.t('list.success_item', index: index + 1, item: order.item, name: order.orderer)
      end
      respond list.join("\n")
    end
  else
    respond I18n.t('list.no_run')
  end
end

def here(params)
  if run = current_user_run(params)
    run.update(active: false)
    respond_in_channel I18n.t('here.success', name: run.runner)
  else
    respond I18n.t('here.no_run')
  end
end

def help
  respond I18n.t('help')
end

def current_user_run(params)
  run = Run.active.in_channel(params['team_id'], params['channel_id']).by_user(params['user_id']).first
  deactivate_if_timed_out(run)
end

def current_channel_run(params)
   run = Run.active.in_channel(params['team_id'], params['channel_id']).first
   deactivate_if_timed_out(run)
end

def deactivate_if_timed_out(run)
  if run && run.timed_out?
    run.update(active: false)
    nil
  else
    run
  end
end

def respond(text)
  {text: text}
end

def respond_in_channel(text)
  {response_type: 'in_channel', text: text}
end
