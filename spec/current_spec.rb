require './spec/spec_helper'

describe Current do
  describe '::channel_run' do
    before do
      Run.destroy_all
    end

    it 'returns the run when there is a run in the channel' do
      run = Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner')
      Current.channel_run('T1', 'C1').must_equal run
    end

    it 'returns nil when the run is in a different channel' do
      Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner')
      Current.channel_run('T1', 'C2').must_be_nil
    end

    it 'returns nil when the run is in a different team' do
      Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner')
      Current.channel_run('T2', 'C1').must_be_nil
    end

    it 'returns nil when the run is inactive' do
      Run.create(team_id: 'T1', channel_id: 'C1', user_id: 'U1', runner: 'runner', active: false)
      Current.channel_run('T1', 'C1').must_be_nil
    end
  end
end
