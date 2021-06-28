class CreateMeasures < ActiveRecord::Migration[6.1]
  def change
    create_table :measures do |t|
      t.datetime :when
      t.integer :sensor
      t.string :ship
      t.integer :magtobossometric_value
      t.boolean :is_in_cluster

      t.timestamps
    end
  end
end
