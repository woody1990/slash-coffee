require './models/run'
require './models/order'

class Commands
  def self.run_command(params)  
    args = params['text'].split
    response = case args.first
      when 'run' then start(args[1], params)
      when 'order' then order(params['user_name'], params['user_id'], args[1..-1].join(' '), params)
      when 'list' then list(params)
      when 'here' then here(params)
      else help
    end
  end

  private

  def self.start(time, params)
    if run = current_channel_run(params)
      respond I18n.t('commands.start.already_on_run', name: run.runner)
    else
      if time.nil?
        respond I18n.t('commands.start.time_missing')
      else
        run = Run.create(
          team_id: params['team_id'], 
          channel_id: params['channel_id'], 
          user_id: params['user_id'],
          runner: params['user_name'],
          time: time)
        respond_in_channel I18n.t('commands.start.success', name: run.runner, time: time)
      end
    end
  end

  def self.order(user_name, user_id, item, params)
    if run = current_channel_run(params)
      if item.nil?
        respond I18n.t('commands.order.order_missing', name: run.runner)
      else
        run.orders.create(orderer: user_name, orderer_id: user_id, item: item)
        respond I18n.t('commands.order.success', item: item)
      end
    else
      respond I18n.t('commands.order.no_run')
    end
  end

  def self.list(params)
    if run = current_channel_run(params)
      if run.orders.empty?
        respond I18n.t('commands.list.no_orders')
      else
        list = [I18n.t('commands.list.success_header')]
        run.orders.each_with_index do |order, index|
          list << I18n.t('commands.list.success_item', index: index + 1, item: order.item, name: order.orderer)
        end
        respond list.join("\n")
      end
    else
      respond I18n.t('commands.list.no_run')
    end
  end

  def self.here(params)
    if run = current_user_run(params)
      run.update(active: false)
      if run.orders.empty?
        respond I18n.t('commands.here.success')
      else
        tags = run.orders.map { |order| "<@#{order.orderer_id}>" }.join(' ')
        respond_in_channel I18n.t('commands.here.success_with_tags', tags: tags, name: run.runner)
      end
    else
      respond I18n.t('commands.here.no_run')
    end
  end

  def self.help
    respond I18n.t('commands.help')
  end

  def self.current_user_run(params)
    run = Run.active.in_channel(params['team_id'], params['channel_id']).by_user(params['user_id']).first
    deactivate_if_timed_out(run)
  end

  def self.current_channel_run(params)
     run = Run.active.in_channel(params['team_id'], params['channel_id']).first
     deactivate_if_timed_out(run)
  end

  def self.deactivate_if_timed_out(run)
    if run && run.timed_out?
      run.update(active: false)
      nil
    else
      run
    end
  end

  def self.respond(text)
    {text: text}
  end

  def self.respond_in_channel(text)
    {response_type: 'in_channel', text: text}
  end
end
