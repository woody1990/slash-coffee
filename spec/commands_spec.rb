require './spec/spec_helper'

describe Commands do
  before do
    Run.destroy_all
    Order.destroy_all
  end

  describe '::start' do
  end

  describe '::order' do
  end

  describe '::list' do
    it 'retuns an error when there is no run' do
      Commands.send(:list, nil).must_equal({text: I18n.t('commands.list.no_run')})
    end

    it 'returns an error when there are no orders' do
      run = Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner')
      Commands.send(:list, run).must_equal({text: I18n.t('commands.list.no_orders')})
    end

    it 'returns a list of orders when there are orders' do
      run = Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner')
      run.orders.create(orderer: 'orderer', orderer_id: 'U2', item: 'latte')
      expected_text = [
        I18n.t('commands.list.success_header'),
        I18n.t('commands.list.success_item', index: 1, item: 'latte', name: 'orderer')
      ].join("\n")
      Commands.send(:list, run).must_equal({text: expected_text})
    end
  end

  describe '::here' do
    it 'retuns an error when there is no run' do
      Commands.send(:here, nil, 'U1').must_equal({text: I18n.t('commands.here.no_run')})
    end

    it 'returns an error when the run is not by the current user' do
      run = Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U2', runner: 'runner')
      Commands.send(:here, run, 'U1').must_equal({text: I18n.t('commands.here.no_run')})
    end

    describe 'when there are no orders' do
      before do
        @run = Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner')
      end

      it 'retuns a private confirmation' do
        Commands.send(:here, @run, 'U1').must_equal({text: I18n.t('commands.here.success')})
      end

      it 'deactivates the run' do
        Commands.send(:here, @run, 'U1')
        @run.active.must_equal false
      end
    end

    describe 'when there are orders' do
      before do
        @run = Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner')
        @run.orders.create(orderer: 'orderer', orderer_id: 'U2', item: 'latte')
      end

      it 'retuns a public message' do
        expected_text = I18n.t('commands.here.success_with_tags', tags: '<@U2>', name: @run.runner)
        Commands.send(:here, @run, 'U1').must_equal({text: expected_text, response_type: 'in_channel'})
      end

      it 'deactivates the run' do
        Commands.send(:here, @run, 'U1')
        @run.active.must_equal false
      end
    end
  end

  describe '::help' do
    it 'returns the help text' do
      Commands.send(:help).must_equal({text: I18n.t('commands.help')})
    end
  end
end
