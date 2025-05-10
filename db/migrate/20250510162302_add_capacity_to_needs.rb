class AddCapacityToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :capacity, :integer
  end
end
