require './app/models/run'
require './app/models/order'
require './app/current'
require './app/slack_response'

class Commands
  def initialize(params)
    @text = params['text']
    @team_id = params['team_id']
    @channel_id = params['channel_id']
    @user_id = params['user_id']
    @user_name = params['user_name']
  end

  def run
    args = @text.split
    return case args.first
    when 'run' then start(args[1])
    when 'order' then order(args[1..-1].join(' '))
    when 'list' then list
    when 'here' then here
    else help
    end
  end

  private

  def start(time)
    if run = Current.channel_run(@team_id, @channel_id)
      return SlackResponse.ephemaral I18n.t('commands.start.already_on_run', name: run.runner)
    else
      run = Run.create(
        team_id: @team_id,
        channel_id: @channel_id,
        user_id: @user_id,
        runner: @user_name,
        time: time)
      if time.nil?
        return SlackResponse.in_channel I18n.t('commands.start.success', name: run.runner)
      else
        return SlackResponse.in_channel I18n.t('commands.start.success_with_time', name: run.runner, time: time)
      end
    end
  end

  def order(item)
    if run = Current.channel_run(@team_id, @channel_id)
      if item.nil?
        return SlackResponse.ephemaral I18n.t('commands.order.order_missing', name: run.runner)
      else
        run.orders.create(orderer: @user_name, orderer_id: @user_id, item: item)
        return SlackResponse.ephemaral I18n.t('commands.order.success', item: item)
      end
    else
      return SlackResponse.ephemaral I18n.t('commands.order.no_run')
    end
  end

  def list
    if run = Current.channel_run(@team_id, @channel_id)
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

  def here
    if run = Current.user_run(@team_id, @channel_id, @user_id)
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

  def help
    return SlackResponse.ephemaral I18n.t('commands.help')
  end
end
