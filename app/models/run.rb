class Run < ActiveRecord::Base
  has_many :orders

  scope :active,     -> { where(active: true) }
  scope :in_channel, ->(team, channel) { where(team_id: team, channel_id: channel) }
  scope :by_user,    ->(user) { where(user_id: user) }
end
