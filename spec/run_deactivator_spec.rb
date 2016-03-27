require './spec/spec_helper'

class Minitest::Spec
  def self.it_deactivates_and_returns_nil(run)
    it 'deactives the run and returns nil' do
      result = RunDeactivator.deactivate_if_timed_out(run)
      result.must_be_nil
      run.active?.must_equal false
    end
  end

  def self.it_does_not_deactivate_and_returns_run(run)
    it 'does not deactive the run and returns it' do
      result = RunDeactivator.deactivate_if_timed_out(run)
      result.must_equal run
      run.active?.must_equal true
    end
  end
end

describe RunDeactivator do
  describe '::deactivate_if_timed_out' do
    it 'returns nil if run is nil' do
      RunDeactivator.deactivate_if_timed_out(nil).must_be_nil
    end

    describe 'when the run has no delay and was created 2 hours ago' do
      run = Run.create(team_id: 'test', channel_id: 'test', user_id: 'test', runner: 'test', time: nil, created_at: 2.hours.ago)
      it_deactivates_and_returns_nil(run)
    end

    describe 'when the run has a 10 minute delay and was created 2 hours ago' do
      run = Run.create(team_id: 'test', channel_id: 'test', user_id: 'test', runner: 'test', time: 10, created_at: 2.hours.ago)
      it_deactivates_and_returns_nil(run)
    end

    describe 'when the run has no delay and was created 1 hour ago' do
      run = Run.create(team_id: 'test', channel_id: 'test', user_id: 'test', runner: 'test', time: nil, created_at: 1.hour.ago)
      it_does_not_deactivate_and_returns_run(run)
    end

    describe 'when the run has a 40 minute delay and was created 2 hours ago' do
      run = Run.create(team_id: 'test', channel_id: 'test', user_id: 'test', runner: 'test', time: 40, created_at: 2.hours.ago)
      it_does_not_deactivate_and_returns_run(run)
    end

    describe 'when the run is not active' do
      run = Run.create(team_id: 'test', channel_id: 'test', user_id: 'test', runner: 'test', active: false)
      it_deactivates_and_returns_nil(run)
    end
  end
end
