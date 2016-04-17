class AddTeamDomainAndChannelName < ActiveRecord::Migration
  def change
    add_column :runs, :team_name, :string
    add_column :runs, :channel_name, :string
  end
end
