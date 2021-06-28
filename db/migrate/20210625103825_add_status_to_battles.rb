class AddStatusToBattles < ActiveRecord::Migration[6.1]
  def change
    add_column :battles, :status, :string
  end
end
