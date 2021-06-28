class AddBoddyGardToMeasurement < ActiveRecord::Migration[6.1]
  def change
    add_column :measures, :is_bodyguard, :boolean, default: false
  end
end
