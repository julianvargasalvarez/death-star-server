class CreateBattles < ActiveRecord::Migration[6.1]
  def change
    create_table :battles do |t|
      t.string :name

      t.timestamps
    end
  end
end
