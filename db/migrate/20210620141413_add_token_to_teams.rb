class AddTokenToTeams < ActiveRecord::Migration[6.1]
  def change
    add_column :teams, :token, :uuid
  end
end
