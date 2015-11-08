require 'sinatra'
require 'sinatra/activerecord'
require './models/run'
require './models/order'
require './config/environments'

post '/coffee' do
  content_type :json

  args = params['text'].split
  response = case args.first
  when 'run' then start(args[1], params)
  when 'order' then order(params['user_name'], args[1], params)
  when 'list' then list(params)
  when 'here' then here(params)
  else help
  end
  response.to_json
end

def start(time, params)
  if run = current_team_run(params)
    respond "#{run.runner} is already on a run! If that's not true, tell them to type `/coffee here` to signal that they came back."
  else
    if time.nil?
      respond 'Let the team know in how many minutes you are leaving. For example, `/coffee run 15`'
    else
      run = Run.create(
        team_id: params['team_id'], 
        channel_id: params['channel_id'], 
        user_id: params['user_id'],
        runner: params['user_name'],
        time: time)
      respond_in_channel "#{run.runner} is going on a coffee run in #{time} minutes! :coffee:\nLet them know what you want with `/coffee order [item]`."
    end
  end
end

def order(user, item, params)
  if run = current_team_run(params)
    if item.nil?
      respond "#{run.runner} needs to know what you want! Try `/coffee order cappuccino` for example."
    else
      run.orders.create(orderer: user, item: item)
      respond "Great! Your #{item} was added to the list."
    end
  else
    respond 'No one is on a run now. Use `/coffee run` to go yourself!'
  end
end

def list(params)
  if run = current_team_run(params)
    list = ['This is the list for the current run:']
    run.orders.each_with_index do |order, index|
      list << "#{index + 1}. #{order.item} for #{order.orderer}"
    end
    respond list.join("\n")
  else
    respond 'No one is on a run now. Use `/coffee run` to go yourself!'
  end
end

def here(params)
  if run = current_user_run(params)
    run.update(active: false)
    respond_in_channel "#{run.runner} is here with coffee! Grab it while it's hot! :coffee:"
  else
    respond "Seems like you weren't on a run :confused:"
  end
end

def help
  respond help_text
end

def current_user_run(params)
  Run.active.in_team(params['team_id']).by_user(params['user_id']).first
end

def current_team_run(params)
   Run.active.in_team(params['team_id']).first
end

def respond(text)
  {text: text}
end

def respond_in_channel(text)
  {response_type: 'in_channel', text: text}
end

def help_text
<<-HELP
/coffee is a slash command to organize coffee runs.

Here are the available commands:

  /coffee run [time]
    Start a coffee run!
    Optionally, anounce in how long you'll be leaving.
    example: /coffee run 15

  /coffee list
    Show the list of orders for the current run.
    example: /coffee list

  /coffee order [item]
    Order something from the current run.
    example: /coffee order small cappuccino

  /coffee here
    Let everyone know that the coffee is here!
    example: /coffee here

  /coffee help
    Show this help message.
    example: /coffee help

Enjoy!
HELP
end
