class RunDeactivator
  TIMEOUT_THRESHOLD = 90.minutes

  def self.deactivate_if_timed_out(run)
    if timed_out?(run)
      run.update(active: false)
      nil
    else
      run
    end
  end

  private

  def self.timed_out?(run)
    return nil unless run

    offset = run.time.try(:minutes) || 0
    Time.now.utc > (run.created_at + offset + TIMEOUT_THRESHOLD).utc
  end
end
