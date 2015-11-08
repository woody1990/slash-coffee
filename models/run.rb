class Run < ActiveRecord::Base
  has_many :orders

  scope :active, -> { where(active: true) }
  scope :in_team, ->(team) { where(team_id: team) }
  scope :by_user, ->(user) { where(user_id: user) }
end
