class AddDateNeededToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :date_needed, :date
  end
end
