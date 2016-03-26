require './app/models/run'
require './app/models/order'
require './app/slack_response'

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
      return SlackResponse.ephemaral I18n.t('commands.start.already_on_run', name: run.runner)
    else
      run = Run.create(
        team_id: params['team_id'],
        channel_id: params['channel_id'],
        user_id: params['user_id'],
        runner: params['user_name'],
        time: time)
      if time.nil?
        return SlackResponse.in_channel I18n.t('commands.start.success', name: run.runner)
      else
        return SlackResponse.in_channel I18n.t('commands.start.success_with_time', name: run.runner, time: time)
      end
    end
  end

  def self.order(user_name, user_id, item, params)
    if run = current_channel_run(params)
      if item.nil?
        return SlackResponse.ephemaral I18n.t('commands.order.order_missing', name: run.runner)
      else
        run.orders.create(orderer: user_name, orderer_id: user_id, item: item)
        return SlackResponse.ephemaral I18n.t('commands.order.success', item: item)
      end
    else
      return SlackResponse.ephemaral I18n.t('commands.order.no_run')
    end
  end

  def self.list(params)
    if run = current_channel_run(params)
      if run.orders.empty?
        return SlackResponse.ephemaral I18n.t('commands.list.no_orders')
      else
        list = [I18n.t('commands.list.success_header')]
        run.orders.each_with_index do |order, index|
          list << I18n.t('commands.list.success_item', index: index + 1, item: order.item, name: order.orderer)
        end
        return SlackResponse.ephemaral list.join("\n")
      end
    else
      return SlackResponse.ephemaral I18n.t('commands.list.no_run')
    end
  end

  def self.here(params)
    if run = current_user_run(params)
      run.update(active: false)
      if run.orders.empty?
        return SlackResponse.ephemaral I18n.t('commands.here.success')
      else
        tags = run.orders.pluck(:orderer_id).uniq.map { |orderer_id| "<@#{orderer_id}>" }.join(' ')
        return SlackResponse.in_channel I18n.t('commands.here.success_with_tags', tags: tags, name: run.runner)
      end
    else
      return SlackResponse.ephemaral I18n.t('commands.here.no_run')
    end
  end

  def self.help
    return SlackResponse.ephemaral I18n.t('commands.help')
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
end
