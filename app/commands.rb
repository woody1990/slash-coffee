require './app/models/run'
require './app/models/order'
require './app/current'
require './app/slack_response'

class Commands
  def self.execute(team_id, channel_id, user_id, user_name, text)
    current_run = Current.channel_run(team_id, channel_id)
    command, rest = text.split(' ', 2)
    return case command
    when 'run'   then start(current_run, team_id, channel_id, user_id, user_name, rest)
    when 'order' then order(current_run, user_id, user_name, rest)
    when 'list'  then list(current_run)
    when 'here'  then here(current_run, user_id)
    else help
    end
  end

  private

  def self.start(current_run, team_id, channel_id, user_id, user_name, time)
    if current_run
      return SlackResponse.ephemaral I18n.t('commands.start.already_on_run', name: current_run.runner)
    else
      run = Run.create(
        team_id: team_id,
        channel_id: channel_id,
        user_id: user_id,
        runner: user_name,
        time: time)
      if time.nil?
        return SlackResponse.in_channel I18n.t('commands.start.success', name: run.runner)
      else
        return SlackResponse.in_channel I18n.t('commands.start.success_with_time', name: run.runner, time: time)
      end
    end
  end

  def self.order(run, user_id, user_name, item)
    if run
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

  def self.list(run)
    if run
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

  def self.here(run, user_id)
    if run && run.user_id == user_id
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
end
