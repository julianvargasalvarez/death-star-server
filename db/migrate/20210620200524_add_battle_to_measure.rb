class AddBattleToMeasure < ActiveRecord::Migration[6.1]
  def change
    add_reference :measures, :battle, null: false, foreign_key: true
  end
end
