class Run < ActiveRecord::Base
  has_many :orders

  TIMEOUT_THRESHOLD = 90.minutes

  scope :active,     -> { where(active: true) }
  scope :in_channel, ->(team, channel) { where(team_id: team, channel_id: channel) }
  scope :by_user,    ->(user) { where(user_id: user) }

  def timed_out?
    Time.now.utc > (created_at + (time.try(:minutes) || 0) + TIMEOUT_THRESHOLD).utc
  end
end
