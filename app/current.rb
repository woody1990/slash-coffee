require './app/run_deactivator'

class Current
  def self.channel_run(team, channel)
     run = Run.active.in_channel(team, channel).first
     RunDeactivator.deactivate_if_timed_out(run)
  end
end
